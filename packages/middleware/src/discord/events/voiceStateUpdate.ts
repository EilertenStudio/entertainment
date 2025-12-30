import {Events, type VoiceState} from 'discord.js';
import type {DiscordClient} from "../index.js"
import {StreamingRoomManager} from "../../streaming/rooms/index.js";
import {type StreamingUser, StreamingUserAction, StreamingUserManager} from "../../streaming/users/index.js";

export default (client: DiscordClient) => {

  client.on(Events.VoiceChannelEffectSend, () => {
    console.log(`[discord.${Events.VoiceChannelEffectSend}]`)
  });

  client.on(Events.VoiceServerUpdate, () => {
    console.log(`[discord.${Events.VoiceServerUpdate}]`)
  });

  client.on(Events.VoiceStateUpdate, async (oldState: VoiceState, newState: VoiceState) => {
    const user = newState.member?.user!;

    console.log(`[discord.${Events.VoiceStateUpdate}.${user.username}]`, `Update on voice channel`);

    // Utente si entra o cambia canale vocale
    if(oldState.channelId !== newState.channelId) {
      let action = newState.channelId ? StreamingUserAction.JOIN : StreamingUserAction.LEAVE;

      console.log(`[discord.${Events.VoiceStateUpdate}.${user.username}]`, `Has ${action} at ${newState.channel?.name || oldState.channel?.name}`);

      const room = StreamingRoomManager.find({
        channel: {
          id: newState.channelId || oldState.channelId!
        }
      });

      if(room) {
        console.log(`[discord.${Events.VoiceStateUpdate}.${user.username}]`, `Streaming room detected: ${room.id}`);

        const streamingUser: StreamingUser = {
          id: user.id,
          username: user.username
        }

        switch(action) {
          case StreamingUserAction.JOIN:
            await StreamingUserManager.join(streamingUser, room);
            break;
          case StreamingUserAction.LEAVE:
            await StreamingUserManager.leave(streamingUser);
            break;
          default:
            throw new Error(`Streaming action not configigured for user ${user.username}`);
        }
      }
    }
    // Utente cambia stato all'interno di un canale vocale
    else {
      // console.log(`[discord.${Events.VoiceStateUpdate}.${user.username}]`, newState);
      // console.log(`[discord.${Events.VoiceStateUpdate}.${user.username}]`, `New state`);
      // - When requestToSpeakTimestamp is null and suppress is false then the user is a speaker
      return;
    }

    // let action: 'JOIN' | 'LEAVE' | 'OTHER' = 'OTHER';
    //
    // if (oldState.channelId !== newState.channelId) {
    //   action = newState.channelId ? 'JOIN' : 'LEAVE';
    // } else {
    //   // Se l'ID del canale è lo stesso, è un evento di mute/deaf/stream
    //   // Per ora lo ignoriamo o lo marchiamo come OTHER
    //   return;
    // }
    //
    // const eventData: VoiceEventData = {
    //   user: newState.member?.user.username || "Unknown",
    //   action: action,
    //   channelId: (newState.channelId || oldState.channelId) as string
    // };
    //
    // console.log('[discord.event]', eventData);
    // ServerManager.sendPacket(PacketType.VOICE_STATE_UPDATE, eventData);
  });

};