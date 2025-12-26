import {
  type CacheType,
  type ChatInputCommandInteraction, type CommandInteraction,
  type Interaction,
  MessageFlagsBitField,
  SlashCommandBuilder
} from 'discord.js';
import {type DiscordCommand} from '../../discord.js'

export default {
  data: new SlashCommandBuilder()
    .setName('echo')
    .setDescription('Echo message in embedded format')
    .addStringOption((option) => option
      .setName("message")
      .setDescription("The message that we echo")
      .setRequired(true)
      .setMinLength(1)
    ),
  execute: async (interaction: ChatInputCommandInteraction) => {
    await interaction.reply({
      content: interaction.options.get('message')!.value as string,
      flags: MessageFlagsBitField.Flags.Ephemeral,
      withResponse: true
    });
  },
} as DiscordCommand;