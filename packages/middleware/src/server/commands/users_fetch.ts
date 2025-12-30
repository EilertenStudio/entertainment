import {type ServerCommand, ServerManager} from "../index.js";
import users_set from "./users_set.js";

const command = {
  name: 'users_fetch',
  handle: async ({server, client, packet}) => {
    console.log(`[server.client.command.${command.name}.handle]`, packet);

    await ServerManager.sendCommand(users_set)
  }
} as ServerCommand;

export default command;