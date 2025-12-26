import {
  ActionRowBuilder,
  ButtonBuilder,
  ButtonStyle,
  type CacheType,
  type ChatInputCommandInteraction, type CommandInteraction,
  type Interaction,
  MessageFlagsBitField,
  SlashCommandBuilder
} from 'discord.js';
import {type DiscordCommand} from '../../discord.js'

export default {
  data: new SlashCommandBuilder()
    .setName('stink')
    .setDescription('Stick a specific user')
    .addMentionableOption((option) => option
      .setName("entity")
      .setDescription("The entity to stink")
      .setRequired(true)
    ),
  execute: async (interaction: ChatInputCommandInteraction) => {
    const user = interaction.options.getUser("entity")

    const reply = new ButtonBuilder()
      .setCustomId('reply')
      .setLabel('Reply Back!')
      .setStyle(ButtonStyle.Danger);

    const end = new ButtonBuilder()
      .setCustomId('surrender')
      .setLabel('Surrender')
      .setStyle(ButtonStyle.Secondary);

    const row = new ActionRowBuilder().addComponents(reply, end);

    // @ts-ignore
    const response = await interaction.reply({
      content: `Puzi ${user} :eyes: \n> by ${interaction.user.username}`,
      // components: [row]
      // flags: MessageFlagsBitField.Flags.Ephemeral,
      // options: {
      //   allowedMentions: {
      //     repliedUser: true
      //   }
      // }
    });

    // setTimeout(async () => {
    //   await response.delete();
    // }, 5 * 1000)
  },
} as DiscordCommand;