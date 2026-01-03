import * as configuration from './configuration/index.js';
import * as server from './server/index.js';
import * as discord from './discord/index.js';

configuration.loadSettings();
configuration.loadCredentials();

server.start();
discord.start();