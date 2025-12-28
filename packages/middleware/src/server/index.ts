import {WebSocketServer} from "ws";
import {Collection, GatewayIntentBits, REST, Routes, SlashCommandBuilder} from "discord.js";
import path from "node:path";
import fs from "node:fs";
import type {GodotPacket, VoiceEventData} from "../types.js";

export interface ServerPacket {
  timestamp: number
  type: ServerPacketType,
  data: any
}

export enum ServerPacketType {
  ANNOUNCEMENT = 'announcement',
  VOICE_STATE_UPDATE = "voiceStateUpdate",
}

export interface ServerCommand {
  data: SlashCommandBuilder;
  execute: () => Promise<void>;
}

export class Server extends WebSocketServer {
  commands: Collection<string, ServerCommand> = new Collection();
  // events: Collection<string, ServerEvent> = new Collection();
}

export class ServerContext {

   server?: Server;

  public send(type: ServerPacketType, data: any): void {
    if (!this.server) {
      throw new Error("Server not initialized yet!")
    }
    // console.log('[server.send.clients]', this.server.clients);

    this.server.clients.forEach(client => {
      console.log(`[server.send.client.${client.url}]`, "Ready for send");

      if(client && client.readyState === WebSocket.OPEN) {
        const packet: ServerPacket = {
          timestamp: new Date().getTime(),
          type,
          data
        }
        client.send(
          JSON.stringify(packet)
        )
      }
    });
  }
}

export const ServerManager = new ServerContext();

// let index: WebSocketServer;
// let serverServer: WebSocket | null;

// export function start() {
//   index = new WebSocketServer({
//     port: Number(process.env.SERVER_PORT) || 8080
//   });
//
//   index.on('connection', (ws: WebSocket) => {
//     console.log('[server.connection]', 'Server connected');
//     serverServer = ws;
//
//     ws.on('error', (error: Error) => {
//       console.error('[server.error]', error);
//     });
//
//     ws.on('message', (data) => {
//       console.log('[server.message]', data.toString());
//     });
//
//     ws.on('close', (code: number, reason: Buffer) => {
//       console.log('[server.close]', `Server disconnected: ${reason.toString() || code}`);
//       serverServer = null;
//     });
//   });
// }

export function start() {
  initServer()
    .then(initServerEvents)
    .then(initServerCommands)
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

export async function getServerEvents(server: Server) {
  // console.log(server.events);
  // TODO: register events as server attribute
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

    server.commands.set(command.data.name, command);
  }


  await getServerCommands(server);

  return server;
}

export async function getServerCommands(server: Server) {
  // console.log(server.commands);
  return server;
}
