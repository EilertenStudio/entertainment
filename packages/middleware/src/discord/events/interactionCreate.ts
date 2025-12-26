import {type Client, Events, type Interaction, MessageFlagsBitField} from 'discord.js';
import type {DiscordClient} from "../../discord.js";

export default (client: DiscordClient) => {

  client.on(Events.InteractionCreate, async (interaction: Interaction) => {
    if(!interaction.isChatInputCommand()) return;

    const command = client.commands.get(interaction.commandName);

    if (!command) {
      console.error(`No command matching ${interaction.commandName} was found.`);
      return;
    }

    try {
      await command.execute(interaction);
    } catch (error) {
      console.error(error);
      if(interaction.replied || interaction.deferred) {
        await interaction.followUp({
          content: 'There was an error while executing this command!',
          flags: MessageFlagsBitField.Flags.Ephemeral
        })
      } else {
        await interaction.reply({
          content: 'There was an error while executing this command!',
          flags: MessageFlagsBitField.Flags.Ephemeral
        })
      }
    }
  });

};