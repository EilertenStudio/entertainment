import {type ServerCommand, ServerManager} from "../index.js";
import {StreamingUserManager} from "../../streaming/users/index.js";

const command = {
  name: 'users_set',
  send: async () => {
    console.log(`[server.client.command.${command.name}.send]`);

    await ServerManager.sendPacket(command.name, StreamingUserManager.data)
  }
} as ServerCommand;

export default command;