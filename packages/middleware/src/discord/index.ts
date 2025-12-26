import * as configuration from '../configuration.js';
import * as discord from '../discord.js';

configuration.loadCredentials();

discord.register_commands()