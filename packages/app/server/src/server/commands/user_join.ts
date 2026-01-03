import {type ServerCommand, ServerManager} from "../index.js";
import {StreamingManager} from "../../streaming/index.js";

const command = {
  name: 'user_join',
  send: async ({ user }) => {
    console.log(`[server.client.command.${command.name}.send]`, user);

    await ServerManager.sendPacket(command.name, user)
  }
} as ServerCommand;

export default command;