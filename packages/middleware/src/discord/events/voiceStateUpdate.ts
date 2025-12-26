import {type Client, Events, type VoiceState} from 'discord.js';
import {PacketType, type VoiceEventData} from "../../types.js";
import * as server from "../../server.js";
import type {DiscordClient} from "../../discord.js";

export default (client: DiscordClient) => {

  client.on(Events.VoiceStateUpdate, (oldState: VoiceState, newState: VoiceState) => {
    let action: 'JOIN' | 'LEAVE' | 'OTHER' = 'OTHER';

    if (oldState.channelId !== newState.channelId) {
      action = newState.channelId ? 'JOIN' : 'LEAVE';
    } else {
      // Se l'ID del canale è lo stesso, è un evento di mute/deaf/stream
      // Per ora lo ignoriamo o lo marchiamo come OTHER
      return;
    }

    const eventData: VoiceEventData = {
      user: newState.member?.user.username || "Unknown",
      action: action,
      channelId: (newState.channelId || oldState.channelId) as string
    };

    console.log('[discord]', '[event]', eventData);
    server.sendData(PacketType.VOICE_STATE_UPDATE, eventData);
  });

};