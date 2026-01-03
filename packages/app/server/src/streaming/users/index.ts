import {resolveConfigurationFile} from "../../configuration/index.js";
import {ServerManager} from "../../server/index.js";
import {type StreamingRoom, type StreamingRoomId} from "../rooms/index.js";
import user_join from "../../server/commands/user_join.js";
import user_leave from "../../server/commands/user_leave.js";

export enum StreamingUserAction {
  JOIN = 'join',
  LEAVE = 'leave'
}

export interface StreamingUserRoomIntegration extends StreamingRoomId {
  slot: number
}

export interface StreamingUserId {
  id: string
  username?: string
}

export interface StreamingUser extends StreamingUserId {
  room?: StreamingUserRoomIntegration
}

export interface StreamingUserContainer {
  [key: string]: StreamingUser
}

export interface StreamingUserConfigurationFile {
  users: StreamingUserContainer
}

export class StreamingUserContext {

  // private configFile = {
  //   data: {}
  // }
  private configFile = resolveConfigurationFile("streaming", "users.toml")

  public get data() {
    const data = this.configFile.data as StreamingUserConfigurationFile;

    if (!data.users) {
      data.users = {};
    }

    return data.users;
  }

  private set data(value: StreamingUserContainer) {
    const data = this.configFile.data as StreamingUserConfigurationFile;

    if (!value) {
      data.users = {}
    } else {
      data.users = value
    }
  }

  public async find(filter: StreamingUserId) {
    this.configFile.load();

    return Object.values(this.data).find(it => it.id === filter.id);
  }

  public async join(user: StreamingUser, room?: StreamingRoom) {
    // console.log('[streaming.user.join.before]', this.data);
    this.configFile.load()

    this.data[user.id] = user;

    if (room) {
      const roomSlotUsedList = Object.values(this.data)
        .filter(it =>
          it.room && it.room.id === room.id
        )
        .map(it =>
          it.room!.slot
        )
        .sort()
      ;

      console.log(`Used room slots: ${roomSlotUsedList}`)

      let roomSlot = 0;
      for(let roomSlotUsed of roomSlotUsedList) {
        console.log(`Check for room slot ${roomSlot}`)
        if(roomSlotUsed !== roomSlot) {
          break;
        }
        roomSlot++;
      }

      if (roomSlot >= room.settings.maxSlots) {
        throw new Error(`User ${user.username} can not take a seat in the streaming room. Max slot number ${room.settings.maxSlots}`)
      }
      user.room = {
        id: room.id,
        slot: roomSlot
      }
    }

    // console.log('[streaming.user.join.after]', this.data);

    this.configFile.save();

    await ServerManager.sendCommand(user_join, { user });
  }

  public async leave(filter: StreamingUser) {
    // console.log('[streaming.user.join.before]', this.data);

    const user = await this.find(filter);

    if(!user) {
      throw new Error("Can not found the user in runtime")
    }

    console.log("User leaved: ", user)
    await ServerManager.sendCommand(user_leave, {user});

    delete this.data[user.id];

    // console.log('[streaming.user.join.after]', this.data);

    this.configFile.save();
  }

}

export const StreamingUserManager = new StreamingUserContext();