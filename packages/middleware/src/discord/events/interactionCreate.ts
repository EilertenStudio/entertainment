import {
  ChatInputCommandInteraction,
  type Client,
  EmbedBuilder,
  Events,
  type Interaction,
  MessageFlagsBitField
} from 'discord.js';
import type {DiscordClient} from "../index.js"

export default (client: DiscordClient) => {

  client.on(Events.InteractionCreate, async (interaction: Interaction) => {
    console.warn('[discord]', `Get interaction of type`, interaction.type,
      `(command: ${interaction.isCommand()})`,
      `(button: ${interaction.isButton()})`,
      `(menu: ${interaction.isStringSelectMenu()})`
    )
    if(interaction.isCommand()) {
      const command = client.commands.get(interaction.commandName);

      if (!command) {
        console.error(`No command matching ${interaction.commandName} was found.`);
        interaction.reply({
          content: `No routine found. Abort operation`,
          flags: MessageFlagsBitField.Flags.Ephemeral
        });
        return;
      }

      if(command.typeAllowed && !command.typeAllowed?.find(it => it.name === interaction.constructor.name)) {
        return;
      }

      // TODO: add command ROLES and manage it with a new .toml file credentials
      // if (isAuthorizedUser(interaction.user.id !== AUTHORIZED_USER_ID)) {
      //   return interaction.reply({
      //     content: 'You are not authorized to use this command.',
      //     ephemeral: true
      //   });
      // }

      try {
        await command.execute(interaction);
      } catch (error: any) {
        console.error(error);

        const embed = new EmbedBuilder()
          // .setTitle(`Session terminated. ${error.message}`,)
          .setTitle(`${error.message}`)
          .setColor(0xFF4400)
        ;

        if(error.cause) {
          embed.addFields(
            {name: "caused by", value: error.cause.message}
          )
        }

        if (interaction.replied || interaction.deferred) {
          await interaction.followUp({
            flags: MessageFlagsBitField.Flags.Ephemeral,
            embeds: [
              embed
            ]
          })
        } else {
          await interaction.reply({
            flags: MessageFlagsBitField.Flags.Ephemeral,
            embeds: [
              embed
            ]
          })
        }
      }
    }
  });

};