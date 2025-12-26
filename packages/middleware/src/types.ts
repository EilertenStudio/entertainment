import {SlashCommandBuilder, CommandInteraction, type ClientEvents} from 'discord.js';

export enum PacketType {
  VOICE_STATE_UPDATE = "voiceStateUpdate",
  // Aggiungi qui altri tipi in futuro, es: TASK_UPDATE
}

export interface VoiceEventData {
  user: string;
  action: 'JOIN' | 'LEAVE' | 'OTHER';
  channelId: string;
}

export interface GodotPacket {
  type: string;
  data: VoiceEventData | any;
  timestamp: Date;
}