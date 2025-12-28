import {resolveConfigurationFile} from "../../configuration/index.js";

export interface StreamingRoom {
  id: string,
  discord?: StreamingRoomDiscordIntegration
}

export interface StreamingRoomDiscordIntegration {
  channel: {
    id: string
  }
}

export interface StreamingRoomConfigurationFile {
  rooms: {
    [key: string]: StreamingRoom
  }
}

export class StreamingRoomContext {

  config = resolveConfigurationFile("streaming", "rooms", "config.toml")

  list(): StreamingRoom[] {
    this.config.load();

    const data = this.config.data as StreamingRoomConfigurationFile;

    return Object.values(data.rooms) || [];
  }

  enroll(room: StreamingRoom) {
    const data = this.config.data as StreamingRoomConfigurationFile;
    // console.log('[before]', data);

    if (!data.rooms) {
      data.rooms = {};
    }
    data.rooms[room.id] = room;

    // console.log('[after]', data)

    this.config.data = data
  }

  discard(room: StreamingRoom) {
    const data = this.config.data as StreamingRoomConfigurationFile;
    // console.log('[before]', data);

    if (!data.rooms) {
      data.rooms = {};
    }

    if (!data.rooms[room.id]) {
      throw new Error(`Room with id \`${room.id}\` not found`)
    }

    delete data.rooms[room.id];

    // console.log('[after]', data)

    this.config.data = data
  }
}

export const StreamingRoomManager = new StreamingRoomContext();