import dotenv from 'dotenv';
import {Client, Events, GatewayIntentBits, VoiceState} from "discord.js";
import {WebSocket, WebSocketServer} from 'ws';
import {type GodotPacket, PacketType, type VoiceEventData} from '../types.js';

dotenv.config();


dotenv.config();

let index : WebSocketServer;
let serverClient: WebSocket | null;

export function start() {
  index = new WebSocketServer({
    port: Number(process.env.SERVER_PORT) || 8080
  });

  index.on('connection', (ws: WebSocket) => {
    console.log('[server]', '[connection]', 'Client connected');
    serverClient = ws;

    ws.on('error', (error: Error) => {
      console.error("[server]", '[error]', error);
    });

    ws.on('message', (data) => {
      console.log("[server]", '[message]', data.toString());
    });

    ws.on('close', (code: number, reason: Buffer) => {
      console.log('[server]', '[close]', `Client disconnected: ${reason.toString() || code}`);
      serverClient = null;
    });
  });
}

export function sendData(type: string, data: VoiceEventData | any): void {
  if (serverClient && serverClient.readyState === WebSocket.OPEN) {
    const packet: GodotPacket = {type, data, timestamp: new Date()};
    serverClient.send(JSON.stringify(packet));
    console.log('[server]', `Sent packet to server: ${type}`);
  }
}