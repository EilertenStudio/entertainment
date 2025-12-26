import fs from 'node:fs';
import path from 'node:path';
import {
  Client, Collection, Events, GatewayIntentBits, REST, VoiceState, Routes, SlashCommandBuilder,
  CommandInteraction
} from "discord.js";
import {PacketType, type VoiceEventData} from "./types.js";

import {sendData} from './server.js'

export interface DiscordCommand {
  data: SlashCommandBuilder | any;
  execute: (interaction: CommandInteraction) => Promise<void>;
}

export class DiscordClient extends Client {
  commands: Collection<string, DiscordCommand> = new Collection();
}

export function start() {
  init_client()
    .then(init_events)
    .then(init_commands)
    .then(async (client) => {
      await client.login(process.env.DISCORD_BOT_TOKEN);
      return client;
    })
    .then(get_commands)
}

async function init_client() {
  return new DiscordClient({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.GuildMessageTyping,
      GatewayIntentBits.GuildVoiceStates,
    ]
  });
}

async function init_events(client: DiscordClient) {
  const foldersPath = path.join('src', 'discord', 'events');
  const eventFiles = fs.readdirSync(foldersPath, {recursive: true, withFileTypes: true}).filter(it => it.name.endsWith(".ts"));

  for (const eventFile of eventFiles) {
    const filePath = path.join(foldersPath, eventFile.name)
      .replace("src", '.')
      .replaceAll(path.sep, "/");

    (await import(filePath)).default(client);
  }

  return client;
}

async function init_commands(client: DiscordClient) {
  const foldersPath = path.join('src', 'discord', 'commands');
  const commandFiles = fs.readdirSync(foldersPath, {recursive: true, withFileTypes: true}).filter(it => it.name.endsWith(".ts"));

  for (const commandFile of commandFiles) {
    const filePath = path.join(foldersPath, commandFile.name)
      .replace("src", '.')
      .replaceAll(path.sep, "/");

    const command = (await import(filePath)).default as DiscordCommand;

    client.commands.set(command.data.name, command);
  }

  return client;
}

export async function get_commands() {
  const rest = new REST().setToken(process.env.DISCORD_BOT_TOKEN!);

  const data = (await rest.get(Routes.applicationCommands(process.env.DISCORD_APP_ID!))) as string[];

  console.log(data)
}

export async function register_commands() {
  const foldersPath = path.join('src', 'discord', 'commands');
  const commandFiles = fs.readdirSync(foldersPath, {recursive: true, withFileTypes: true}).filter(it => it.name.endsWith(".ts"));

  const commands: string[] = [];

  async function collect_command_data() {
    for (const commandFile of commandFiles) {
      const filePath = path.join(foldersPath, commandFile.name)
        .replace("src", '.')
        .replaceAll(path.sep, "/");

      console.log(`Collecting command ${filePath}`)

      const command = (await import(filePath)).default as DiscordCommand;

      commands.push(command.data.toJSON());
    }
  }

  async function send_command_data() {
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

  await collect_command_data();
  await send_command_data();
}