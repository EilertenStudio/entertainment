import {type ServerCommand, ServerManager} from "../index.js";
import {StreamingManager} from "../../streaming/index.js";

const command = {
  name: 'configuration_set',
  // handle: async (server, client, packet) => {
  //   console.log(`[server.client.command.${command.name}.handle]`, packet);
  //
  //   StreamingManager.configFile.data = packet.data;
  // },
  send: async () => {
    console.log(`[server.client.command.${command.name}.send]`);
    StreamingManager.configFile.load()

    await ServerManager.sendPacket(command.name, StreamingManager.configFile.data)
  }
} as ServerCommand;

export default command;