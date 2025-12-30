import {WebSocketServer, WebSocket} from "ws";
import {Collection, GatewayIntentBits, REST, Routes, SlashCommandBuilder} from "discord.js";
import path from "node:path";
import fs from "node:fs";

export enum ServerPacketType {
  COMMAND = 'command',
  ANNOUNCEMENT = 'announcement',
  VOICE_STATE_UPDATE = "voiceStateUpdate",
}

export interface ServerPacket {
  timestamp: number
  name: string,
  data: any
}

export interface ServerCommand {
  name: string;
  handle: (args: { server: Server, client: WebSocket, packet: ServerPacket }) => Promise<void>;
  send?: (args?: any) => Promise<void>;
}

export class Server extends WebSocketServer {
  commands: Collection<string, ServerCommand> = new Collection();
  // events: Collection<string, ServerEvent> = new Collection();
}

export class ServerContext {

   server?: Server;

  public async handleCommand(command: ServerCommand, packet: ServerPacket) {
    if (!this.server) {
      throw new Error("Server not initialized yet!")
    }

    if(!command.handle) {
      throw new Error("Can not handle command due missing send function")
    }

    for (const client of this.server.clients) {
      await command.handle({ server: this.server!, client, packet});
    }
  }

  public async sendCommand(command: ServerCommand, args?: any) {
    if (!this.server) {
      throw new Error("Server not initialized yet!")
    }

    if(command.send) {
      await command?.send(args)
    }
    else {
      throw new Error("Can not send command due missing send function")
    }
  }

  public async sendPacket(name: string, data: any) {
    if (!this.server) {
      throw new Error("Server not initialized yet!")
    }

    let index = 0;
    this.server.clients.forEach((client) => {
      if(client && client.readyState === WebSocket.OPEN) {
        const packet: ServerPacket = {
          timestamp: new Date().getTime() / 1000,
          name: name,
          data
        }

        console.log(`[server.client.packet.${name}]`, packet);

        client.send(JSON.stringify(packet))
      }
    });
  }

  // public findServerCommand(command: ServerCommand) {
  //   return this.server?.commands.find(it => it.name === name)!;
  // }
}

export const ServerManager = new ServerContext();

export function start() {
  initServer()
    .then(initServerEvents)
    .then(initServerCommands)
    .then(initServerListeners)
  ;
}

async function initServer() {
  return ServerManager.server = new Server({
    port: Number(process.env.SERVER_PORT) || 8080
  });
}

async function initServerEvents(server: Server) {
  const foldersPath = path.join('src', 'server', 'events');
  const eventFiles = fs.readdirSync(foldersPath, {
    recursive: true,
    withFileTypes: true
  }).filter(it => it.name.endsWith(".ts"));

  for (const eventFile of eventFiles) {
    const filePath = path.join(foldersPath, eventFile.name)
      .replace(`src${path.sep}server`, '.')
      .replaceAll(path.sep, "/");

    (await import(filePath)).default(server);
  }

  await getServerEvents(server);

  return server;
}

async function initServerCommands(server: Server) {
  const foldersPath = path.join('src', 'server', 'commands');
  const commandFiles = fs.readdirSync(foldersPath, {
    recursive: true,
    withFileTypes: true
  }).filter(it => it.name.endsWith(".ts"));

  for (const commandFile of commandFiles) {
    const filePath = path.join(foldersPath, commandFile.name)
      .replace(`src${path.sep}server`, '.')
      .replaceAll(path.sep, "/");

    const command = (await import(filePath)).default as ServerCommand;

    server.commands.set(command.name, command);
  }


  await getServerCommands(server);

  return server;
}

async function getServerEvents(server: Server) {
  // console.log(server.events);
  // TODO: register events as server attribute
  return server;
}

async function initServerListeners(server: Server) {

  server.on('listening', () => {
    console.log('[server.listening]', 'Server waiting for connections');
  });

  server.on('connection', (client) => {
    console.log('[server.connection]', 'Client connected')//,  client);

    client.on('open', () => {
      console.log('[server.client.open', arguments);
    });

    client.on('close', (code, reason) => {
      console.log('[server.client.close]', `Client disconnected (code: ${code}) (reason: ${reason})`);
    });

    client.on('upgrade', () => {
      console.log('[server.client.upgrade', arguments);
    });

    client.on('error', (error) => {
      console.error('[server.client.error]', error)
    });

    client.on('message', (rawData) => {
      const packet = JSON.parse(rawData.toString()) as ServerPacket;

      const command = server.commands.find(it => it.name === packet.name)
      if(command) {
        ServerManager.handleCommand(command, packet);
      }
      else {
        console.log('[server.client.message]', packet);
      }

    });
  });

  return server
}

async function getServerCommands(server: Server) {
  // console.log(server.commands);
  return server;
}
