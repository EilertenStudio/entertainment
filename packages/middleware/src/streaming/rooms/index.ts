import {resolveConfigurationFile} from "../../configuration/index.js";
import {StreamingManager} from "../index.js";
import configuration_set from "../../server/commands/configuration_set.js";
import {ServerManager} from "../../server/index.js";

export interface StreamingRoomContainer {
  [key: string]: StreamingRoom
}

export interface StreamingRoom extends StreamingRoomId {
  id: string,
  settings?: StreamingRoomSettings
  discord?: StreamingRoomDiscordIntegration
}

export interface StreamingRoomId {
  id: string,
}

export interface StreamingRoomSettings {
  slots?: number,
}

export interface StreamingRoomDiscordIntegration {
  channel: {
    id: string
  }
}

export interface StreamingRoomConfigurationFile {
  rooms: StreamingRoomContainer
}

export class StreamingRoomContext {

  private configFile = StreamingManager.configFile

  private get data() {
    const data = StreamingManager.configFile.data as StreamingRoomConfigurationFile;

    if(!data.rooms) {
      data.rooms = {};
    }

    return data.rooms;
  }

  private set data(value: StreamingRoomContainer) {
    const data = StreamingManager.configFile.data as StreamingRoomConfigurationFile;

    if(!value) {
      data.rooms = {}
    }
    else {
      data.rooms = value
    }
  }

  find(filter: StreamingRoomId | StreamingRoomDiscordIntegration) {
    this.configFile.load();

    if('id' in filter) {
      return Object.values(this.data).find(it => it.id === filter.id)
    }
    if('channel' in filter) {
      return Object.values(this.data).find(it => it?.discord?.channel.id === filter.channel.id)
    }
  }

  list(): StreamingRoom[] {
    this.configFile.load();

    return Object.values(this.data) || [];
  }

  set(room: StreamingRoom) {
    // console.log('[before]', this.data)

    if(room.discord?.channel.id) {
      const roomByChannel = this.find({
        channel: {
          id: room.discord.channel.id
        }
      });

      if(roomByChannel) {
        throw new Error(`Room must have unique discord channel. Already defined in ${room.id}`)
      }
    }

    this.data[room.id] = room;

    // console.log('[after]', this.data)

    this.configFile.save();

    ServerManager.sendCommand(configuration_set).then(r => {});
  }

  unset(filter: StreamingRoomId) {
    if (!this.data[filter.id]) {
      throw new Error(`Room with id '${filter.id}' not found`)
    }

    // console.log('[before]', this.data)

    delete this.data[filter.id];

    // console.log('[after]', this.data)

    this.configFile.save();

    ServerManager.sendCommand(configuration_set).then(r => {});
  }
}

export const StreamingRoomManager = new StreamingRoomContext();