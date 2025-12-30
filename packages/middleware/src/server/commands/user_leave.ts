import {type ServerCommand, ServerManager} from "../index.js";
import {StreamingManager} from "../../streaming/index.js";
import {StreamingUserManager} from "../../streaming/users/index.js";

const command = {
  name: 'user_leave',
  send: async ({ user }) => {
    console.log(`[server.client.command.${command.name}.send]`, user);

    await ServerManager.sendPacket(command.name, user)
  }
} as ServerCommand;

export default command;