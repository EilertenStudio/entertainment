import {
  ButtonStyle,
  ChatInputCommandInteraction,
  EmbedBuilder,
  MessageFlagsBitField,
  SlashCommandBuilder
} from 'discord.js';
import {type DiscordCommand} from '../index.js'
import {type StreamingRoom, StreamingRoomManager} from "../../streaming/rooms/index.js";
import {channel} from "node:diagnostics_channel";

export default {
  typeAllowed: [
    ChatInputCommandInteraction
  ],
  data: new SlashCommandBuilder()
    .setName('streaming')
    .setDescription('Get access to streaming context')
    .addSubcommandGroup(rooms => rooms
      .setName("rooms")
      .setDescription("Get access to streaming rooms context")
      .addSubcommand(cmd => cmd
        .setName('view')
        .setDescription('View all currently enrolled rooms')
      )
      .addSubcommand(cmd => cmd
        .setName('enroll')
        .setDescription('Enroll a new room in the registry')
        .addStringOption(opt => opt
          .setName("id")
          .setDescription("The id of disposed room")
          .setRequired(true)
        )
        .addChannelOption(opt => opt
          .setName("channel")
          .setDescription("The channel to bind at the disposed room")
          .setRequired(true)
        )
      )
      .addSubcommand(cmd => cmd
        .setName('discard')
        .setDescription('Discard a room from the registry')
        .addStringOption(opt => opt
          .setName("id")
          .setDescription("The id of disposed room")
          .setRequired(true)
        )
      )
    )
  ,
  execute: async (interaction: ChatInputCommandInteraction) => {
    const context = interaction.options.getSubcommandGroup();

    switch (context) {
      case 'rooms':
        await handleRooms(interaction)
        break;
      default:
        throw new Error("No context available");
    }
  },
} as DiscordCommand;


async function handleRooms(interaction: ChatInputCommandInteraction) {
  const cmd = interaction.options.getSubcommand();

  switch (cmd) {
    case 'view':
      await handleRoomView(interaction)
      break;
    case 'enroll':
      await handleRoomEnroll(interaction)
      break;
    case 'discard':
      await handleRoomDiscard(interaction)
      break;
    default:
      throw new Error("No subcommand available");
  }
}

async function handleRoomView(interaction: ChatInputCommandInteraction) {
  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral
  });

  const rooms = StreamingRoomManager.list();

  // const markdown = json2md([
  //   {
  //     h2: "List of configured streaming rooms"
  //   },
  //   {
  //     table: {
  //       headers: [
  //         "title", "channel"
  //       ],
  //       rows: data.map(it => ({
  //           title: it.id,
  //           channel: it.discord.channel.id
  //         })
  //       )
  //     }
  //   }
  // ]);
  //
  // await interaction.editReply({
  //   content: markdown
  // });

  const embed = new EmbedBuilder()
    .setTitle("List of configured streaming rooms")
    .setColor(0x0099FF)
  ;

  createEmbedFields(embed, rooms);

  await interaction.editReply({
    embeds: [
      embed
    ]
  });
}

async function handleRoomEnroll(interaction: ChatInputCommandInteraction) {
  const id = interaction.options.getString("id")!;
  const channel = interaction.options.getChannel("channel")!;

  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral,
  });

  const rooms: StreamingRoom[] = [
    {
      id: id,
      discord: {
        channel: {
          id: channel.id
        }
      }
    }
  ];

  try {
    StreamingRoomManager.enroll(rooms[0]!);
  } catch (error) {
    console.log("")
    throw new Error("Can not enroll new room in the registry due an error", {cause: error})
  }

  const embed = new EmbedBuilder()
    .setTitle("Enrolled new room in the registry with success")
    .setColor(0x009944)
  ;

  createEmbedFields(embed, rooms);

  await interaction.editReply({
    embeds: [
      embed
    ]
  });
}

async function handleRoomDiscard(interaction: ChatInputCommandInteraction) {
  const id = interaction.options.getString("id")!;

  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral
  });

  const rooms: StreamingRoom[] = [
    {
      id: id
    }
  ];

  try {
    StreamingRoomManager.discard(rooms[0]!);
  } catch (error) {
    console.log("")
    throw new Error("Can not discard room from the registry due an error", {cause: error})
  }

  const embed = new EmbedBuilder()
    .setTitle("Discarded room in the registry with success")
    .setColor(0x009944)
  ;

  createEmbedFields(embed, rooms);

  await interaction.editReply({
    embeds: [
      embed
    ]
  });
}

function createEmbedFields(embed: EmbedBuilder, rooms: StreamingRoom[]) {
  rooms.forEach((it) => {
    embed.addFields({inline: true, name: 'id', value: `\`${it.id}\``});
    if (it.discord) {
      embed.addFields({inline: true, name: 'channel', value: `<#${it.discord.channel.id}>`});
    }
    embed.addFields({inline: true, name: '\u200B', value: '\u200B'});
  })
}

// export default {
//   typeAllowed: [
//     ChatInputCommandInteraction
//   ],
//   data: new SlashCommandBuilder()
//     .setName('streaming')
//     .setDescription('Get access to streaming context')
//   ,
//   execute: async (interaction: ChatInputCommandInteraction) => {
//     const response = await interaction.reply({
//       content: '`Loading session context`',
//       components: [],
//       withResponse: true,
//       flags: MessageFlagsBitField.Flags.Ephemeral
//     });
//     console.log('[discord.streaming.response]', response)
//
//     if (response && response.resource && response.resource.message) {
//
//       sendMainMenu(interaction)
//         .then(
//           () => createActionCollector(interaction, response!.resource!.message!)
//         )
//     } else {
//       await interaction.editReply({
//         content: "Session terminated due failing on load context"
//       })
//     }
//   },
// } as DiscordCommand;

// async function handleError(interaction: Interaction, error: any) {
//   console.error(error);
//
//   if (interaction.isChatInputCommand()) {
//     await interaction.editReply({
//       content: error.message,
//       components: []
//     });
//   } else if (interaction.isButton() || interaction.isStringSelectMenu()) {
//     await interaction.update({
//       content: error.message,
//       components: []
//     });
//   }
// }
//
// function createActionCollector(interaction: ChatInputCommandInteraction, message: Message) {
//   console.log(`[discord.streaming.collector]`)//, message);
//
//   const collector = message.createMessageComponentCollector({
//     time: 20_000
//   })
//
//   collector.on('collect', async (action) => {
//     let actionId = null;
//
//     if (action.isButton()) {
//       actionId = action.customId;
//     } else if (action.isStringSelectMenu()) {
//       actionId = action.values[0];
//     }
//
//     console.log(`[discord.streaming.collector.collect]`, action.constructor.name, '->', actionId);
//
//     try {
//       switch (actionId) {
//         case 'streaming':
//           await sendMainMenu(action);
//           break;
//         case 'streaming_rooms':
//           await sendRoomsMenu(action);
//           break;
//         default:
//           throw new Error("Session terminated due out of context");
//       }
//     } catch (error: any) {
//       await handleError(interaction, error);
//     }
//   });
//   collector.on('end', async (action) => {
//     console.log(`[discord.streaming.collector.end]`);
//
//     await interaction.editReply({content: '`Session terminated due no input received`', components: []});
//   });
// }
//
// async function sendMainMenu(interaction: Interaction) {
//   const data = {
//     content: '`Streaming | Main Menu`',
//     components: [
//       new ActionRowBuilder()
//         .addComponents(
//           // new ButtonBuilder()
//           //   .setCustomId('streaming_rooms')
//           //   .setLabel('Rooms')
//           //   .setStyle(ButtonStyle.Primary)
//           new StringSelectMenuBuilder()
//             .setCustomId("streaming___select")
//             .addOptions(
//               new StringSelectMenuOptionBuilder()
//                 .setValue("streaming_rooms")
//                 .setLabel("Rooms")
//             )
//         )
//         .toJSON()
//     ],
//   };
//   if (interaction.isChatInputCommand()) {
//     return await interaction.editReply(data);
//   } else if (interaction.isButton()) {
//     return await interaction.update(data);
//   } else {
//     await handleError(interaction, new Error("Session terminated due out of context"));
//   }
// }
//
// async function sendRoomsMenu(interaction: Interaction) {
//   if (interaction.isButton()) {
//     return await interaction.update({
//       content: '`Streaming | Rooms Menu`',
//       components: [
//         new ActionRowBuilder()
//           .addComponents(
//             new ButtonBuilder().setCustomId("streaming").setLabel("Back").setStyle(ButtonStyle.Secondary)
//           )
//           .toJSON()
//       ]
//     });
//   } else {
//     await handleError(interaction, new Error("Session terminated due out of context"));
//   }
// }