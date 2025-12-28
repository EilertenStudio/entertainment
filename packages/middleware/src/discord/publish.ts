import * as configuration from '../configuration/index.js';
import * as discord from './index.js';

configuration.loadCredentials();

discord.registerApplicationCommands()