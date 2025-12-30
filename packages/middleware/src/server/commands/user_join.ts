import {type ServerCommand, ServerManager} from "../index.js";
import {StreamingManager} from "../../streaming/index.js";

const command = {
  name: 'user_join',
  send: async () => {
    console.log(`[server.client.command.${command.name}.send]`);

    // TODO: implement StreamingUserManager and the user registry functionality
    // await ServerManager.sendPacket(command.name, StreamingManager.configFile.data)
  }
} as ServerCommand;

export default command;