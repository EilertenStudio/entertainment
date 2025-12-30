import {type ServerCommand, ServerManager} from "../index.js";
import {StreamingManager} from "../../streaming/index.js";
import configuration_set from "./configuration_set.js";

const command = {
  name: 'configuration_get',
  handle: async (server, client, packet) => {
    console.log(`[server.client.command.${command.name}]`, packet);

    await ServerManager.sendCommand(configuration_set)
  },
} as ServerCommand;

export default command;