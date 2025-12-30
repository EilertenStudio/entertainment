import {
  ButtonStyle,
  ChatInputCommandInteraction,
  EmbedBuilder, GuildChannel,
  MessageFlagsBitField,
  SlashCommandBuilder, StageChannel, VoiceChannel
} from 'discord.js';
import {type DiscordCommand} from '../index.js'
import {type StreamingRoom, StreamingRoomManager} from "../../streaming/rooms/index.js";
import {channel} from "node:diagnostics_channel";
import {ServerManager, ServerPacketType} from "../../server/index.js";
import {PacketType} from "../../types.js";

export default {
  typeAllowed: [
    ChatInputCommandInteraction
  ],
  data: new SlashCommandBuilder()
    .setName('streaming')
    .setDescription('Get access to streaming context')
    // ====================================================================================================
    .addSubcommand(cmd => cmd
      .setName("announce")
      .setDescription("Announce a message on the stream")
      .addStringOption(opt => opt
        .setName("message")
        .setDescription("The message to get announced on stream")
        .setRequired(true)
      )
    )
    // ====================================================================================================
    .addSubcommandGroup(group => group
      .setName("rooms")
      .setDescription("Get access to streaming rooms context")
      // --------------------------------------------------------------------------------------------------
      .addSubcommand(cmd => cmd
        .setName('list')
        .setDescription('List all currently enrolled rooms')
      )
      // --------------------------------------------------------------------------------------------------
      .addSubcommand(cmd => cmd
        .setName('set')
        .setDescription('Set a new room in the registry')
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
        .addNumberOption(opt => opt
          .setName("slots")
          .setDescription("The number of slots allowed in the rooms")
          .setRequired(true)
          .setMinValue(1)
        )
      )
      // --------------------------------------------------------------------------------------------------
      .addSubcommand(cmd => cmd
        .setName('unset')
        .setDescription('Unset a room from the registry')
        .addStringOption(opt => opt
          .setName("id")
          .setDescription("The id of disposed room")
          .setRequired(true)
        )
      )
    )
    // ====================================================================================================
  ,
  execute: async (interaction: ChatInputCommandInteraction) => {
    let cmd = interaction.options.getSubcommandGroup();

    if(!cmd) {
      cmd = interaction.options.getSubcommand();
    }

    switch (cmd) {
      case 'announce':
        await handleAnnounce(interaction)
        break;
      case 'rooms':
        await handleRooms(interaction)
        break;
      default:
        throw new Error("No command available");
    }
  },
} as DiscordCommand;

async function handleAnnounce(interaction: ChatInputCommandInteraction) {
  const message = interaction.options.getString("message");

  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral
  });

  ServerManager.sendPacket(ServerPacketType.ANNOUNCEMENT, {
    message: message
  })

  // TODO: implement a callback to get confirmation

  const embed = new EmbedBuilder()
    .setTitle("Announce sent with succeeded")
    .setColor(0x00FF44)
  ;

  await interaction.editReply({
    embeds: [
      embed
    ]
  });
}

async function handleRooms(interaction: ChatInputCommandInteraction) {
  const cmd = interaction.options.getSubcommand();

  switch (cmd) {
    case 'list':
      await handleRoomList(interaction)
      break;
    case 'set':
      await handleRoomSet(interaction)
      break;
    case 'unset':
      await handleRoomUnset(interaction)
      break;
    default:
      throw new Error("No subcommand available");
  }
}

async function handleRoomList(interaction: ChatInputCommandInteraction) {
  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral
  });

  const rooms = StreamingRoomManager.list();

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

async function handleRoomSet(interaction: ChatInputCommandInteraction) {
  const id = interaction.options.getString("id")!;
  const slots = interaction.options.getNumber("slots")!;
  const channel = interaction.options.getChannel("channel")!;

  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral,
  });

  if(channel instanceof VoiceChannel || channel instanceof StageChannel) {
    await channel.setUserLimit(slots, "Set limit by streaming room space");
  }

  const rooms: StreamingRoom[] = [
    {
      id: id,
      settings: {
        slots: slots,
      },
      discord: {
        channel: {
          id: channel.id
        }
      }
    }
  ];

  try {
    StreamingRoomManager.set(rooms[0]!);
  } catch (error) {
    throw new Error("Can not set room in the registry due an error", {cause: error})
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

async function handleRoomUnset(interaction: ChatInputCommandInteraction) {
  const id = interaction.options.getString("id")!;

  await interaction.deferReply({
    flags: MessageFlagsBitField.Flags.Ephemeral
  });

  const room = StreamingRoomManager.find({ id })

  if(!room) {
    throw new Error(`Room with id \`${id}\` not found!`);
  }

  let channel;
  if(room.discord && room.discord.channel) {
    channel = await interaction.client.channels.fetch(room.discord.channel.id)
  }

  try {
    StreamingRoomManager.unset(room);
  } catch (error) {
    throw new Error("Can not unset room from the registry due an error", {cause: error})
  }

  if(channel) {
    console.log(channel)
    if(channel.isVoiceBased()) {
      await channel.setUserLimit(0, "Unset limit by streaming room space");
    }
  }

  const embed = new EmbedBuilder()
    .setTitle("Discarded room in the registry with success")
    .setColor(0x009944)
  ;

  createEmbedFields(embed, [ room ]);

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
