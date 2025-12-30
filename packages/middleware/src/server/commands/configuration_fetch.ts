import {type ServerCommand, ServerManager} from "../index.js";
import configuration_set from "./configuration_set.js";

const command = {
  name: 'configuration_fetch',
  handle: async ({server, client, packet}) => {
    console.log(`[server.client.command.${command.name}.handle]`, packet);

    await ServerManager.sendCommand(configuration_set)
  },
} as ServerCommand;

export default command;