import fs from 'node:fs';
import path from 'node:path';
import {type} from "node:os";

import {
  Client, Collection, Events, GatewayIntentBits, REST, VoiceState, Routes, SlashCommandBuilder,
  CommandInteraction, type ApplicationCommand, type Interaction
} from "discord.js";

export interface DiscordCommand {
  typeAllowed?: {new(): Interaction}[]
  data: SlashCommandBuilder | any;
  execute: (interaction: CommandInteraction) => Promise<void>;
}

export class DiscordClient extends Client {
  commands: Collection<string, DiscordCommand> = new Collection();
}

export function start() {
  initClient()
    .then(initApplicationEvents)
    .then(initApplicationCommands)
    .then(async (client) => {
      await client.login(process.env.DISCORD_BOT_TOKEN);
      return client;
    })
  ;
}

async function initClient() {
  return new DiscordClient({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.GuildMessageTyping,
      GatewayIntentBits.GuildVoiceStates,
    ]
  });
}

async function initApplicationEvents(client: DiscordClient) {
  const foldersPath = path.join('src', 'discord', 'events');
  const eventFiles = fs.readdirSync(foldersPath, {recursive: true, withFileTypes: true}).filter(it => it.name.endsWith(".ts"));

  for (const eventFile of eventFiles) {
    const filePath = path.join(foldersPath, eventFile.name)
      .replace(`src${path.sep}discord`, '.')
      .replaceAll(path.sep, "/");

    (await import(filePath)).default(client);
  }

  return client;
}

async function initApplicationCommands(client: DiscordClient) {
  const foldersPath = path.join('src', 'discord', 'commands');
  const commandFiles = fs.readdirSync(foldersPath, {recursive: true, withFileTypes: true}).filter(it => it.name.endsWith(".ts"));

  for (const commandFile of commandFiles) {
    const filePath = path.join(foldersPath, commandFile.name)
      .replace(`src${path.sep}discord`, '.')
      .replaceAll(path.sep, "/");

    const command = (await import(filePath)).default as DiscordCommand;

    client.commands.set(command.data.name, command);
  }

  return client;
}

export async function registerApplicationCommands() {
  const foldersPath = path.join('src', 'discord', 'commands');
  const commandFiles = fs.readdirSync(foldersPath, {recursive: true, withFileTypes: true}).filter(it => it.name.endsWith(".ts"));

  const commands: string[] = [];

  async function importApplicationCommandData() {
    for (const commandFile of commandFiles) {
      const filePath = path.join(foldersPath, commandFile.name)
        .replace(`src${path.sep}discord`, '.')
        .replaceAll(path.sep, "/");

      console.log(`Collecting command ${filePath}`)

      const command = (await import(filePath)).default as DiscordCommand;

      commands.push(command.data.toJSON());
    }
  }

  async function publishApplicationCommandData() {
    const rest = new REST().setToken(process.env.DISCORD_BOT_TOKEN!);

    try {
      console.log()
      console.log(`Started refreshing ${commands.length} application (/) commands.`);

      const data = (await rest.put(Routes.applicationCommands(process.env.DISCORD_APP_ID!), { body: commands })) as string[];

      console.log(`Successfully reloaded ${data.length} application (/) commands.`);
      console.log()
    } catch(error) {
      console.error(error);
    }
  }

  await importApplicationCommandData();
  await publishApplicationCommandData();
  await getRegisteredApplicationCommands()
}

export async function getRegisteredApplicationCommands() {
  const rest = new REST().setToken(process.env.DISCORD_BOT_TOKEN!);

  const commands = (await rest.get(Routes.applicationCommands(process.env.DISCORD_APP_ID!)));

  // console.log(typeof commands)
  console.log(commands);
}