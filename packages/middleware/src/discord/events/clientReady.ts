import {type Client, Events} from 'discord.js';
import type {DiscordClient} from "../index.js"

export default (client: DiscordClient) => {

  client.once(Events.ClientReady, (c) => {
    console.log('[discord.clientReady]', `Agent is online as ${c.user.tag}`);
  });

};