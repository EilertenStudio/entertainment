import dotenv from 'dotenv';
import {Client, GatewayIntentBits } from "discord.js";
import { WebSocketServer } from 'ws';

dotenv.config();

if(process.env['CREDENTIALS_FILE']) {
  dotenv.config({
    path: process.env['CREDENTIALS_FILE']
  });
} else {
  throw new Error("Discord configuration not provided! Use CREDENTIALS_FILE env var.")
}

const server = new WebSocketServer({
  port: process.env.APPLICATION_PORT || 8080
});
var serverClient = null;

const sendToClient = (type, data) => {
  if(serverClient && serverClient.readyState === 1) {
    const packet = JSON.stringify({ type, data, timestamp: new Date() });
    serverClient.send(packet);
    console.log('[server]', `Sent packet to server: ${type}`)
  }
};

server.on('connection', (ws) => {
  console.log('[server]', '[connection]', 'Client connected');

  // TODO: Manage multi-client connection
  serverClient = ws;

  ws.on('error', (data) => {
    console.error("[server]", '[error]', data);
  });

  ws.on('message', function message(data){
    console.log("[server]", '[message]', data)
  });

  ws.on('close', (it) => {
    console.log(it)
    console.log('[server]', '[close]', `Client disconnected for ${serverClient.reason}`)
  })

});

const discord = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.GuildVoiceStates,
  ]
});

discord.login(process.env.DISCORD_BOT_TOKEN).then(() => {

  discord.once('clientReady', () => {
    console.log('[discord]', '[clientReady]', `Agent is online as ${discord.user.tag}`)
  });

  // discord.on('messageCreate', args => {
  //   console.log('[discord]', '[messageCreate]', args);
  // });
  //
  // discord.on('messageUpdate', args => {
  //   console.log('[discord]', '[messageUpdate]', args);
  // });

  discord.on('voiceStateUpdate', (oldState, newState) => {
    // console.log('[discord]', '[voiceStateUpdate]', 'oldState:', oldState)
    // console.log('[discord]', '[voiceStateUpdate]', 'newState:', newState)

    let action;

    if(oldState.channelId !== newState.channelId) {
      action = newState.channelId ? 'JOIN' : 'LEAVE';
    }
    // selfDeaf
    // selfMute
    // selfVideo
    // streaming

    const eventData = {
      user: newState.member.user.username,
      action: action,
      channelId: newState.channelId || oldState.channelId
    };

    console.log(eventData);
    sendToClient("voiceStateUpdate", eventData)
  });
});