import * as configuration from './configuration.js';
import * as server from './server.js';
import * as discord from './discord.js';

configuration.loadSettings();
configuration.loadCredentials();

server.start();
discord.start();