import 'dart:io';

import 'package:mineral/api.dart';
import 'package:mineral/src/infrastructure/internals/voice/audio_player.dart';
import 'package:mineral/src/infrastructure/internals/voice/speaking_mode.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/discord_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/wss/constants/op_code.dart';
import 'package:mineral/src/infrastructure/kernel/kernel.dart';

final class VoiceController {
  final Snowflake serverId;
  final Snowflake channelId;
  final bool selfDeaf;
  final bool selfMute;
  final KernelContract _kernel;
  late final AudioPlayer audioPlayer;

  VoiceController(this._kernel, {
    required this.serverId,
    required this.channelId,
    required this.selfDeaf,
    required this.selfMute,
  });

  Future<void> connect() async {
    print('Connecting to voice channel : $channelId...');
    print(_kernel.shards.length);

    _kernel.shards.forEach((id, shard) {
      print('Sending voice state update to shard : $id');
      final message = ShardMessageBuilder()
        .setOpCode(OpCode.voiceStateUpdate)
        .append('guild_id', serverId)
        .append('channel_id', channelId)
        .append('self_mute', selfMute)
        .append('self_deaf', selfDeaf);

      shard.client.send(message.build());

      print('Connected to voice channel : $channelId');
    });
  }

  Future<void> play(File file) async {
    await audioPlayer.play(file);
  }

  Future<void> disconnect() async {
    print('Disconnecting from voice channel : $channelId...');
    print(_kernel.shards.length);

    _kernel.shards.forEach((id, shard) {
      print('Sending voice state update to shard : $id');
      final message = ShardMessageBuilder()
        .setOpCode(OpCode.voiceStateUpdate)
        .append('guild_id', serverId)
        .append('channel_id', null)
        .append('self_mute', selfMute)
        .append('self_deaf', selfDeaf);

      shard.client.send(message.build());

      print('Disconnected from voice channel : $channelId');
    });
  }

  Future<void> setSelfDeaf(bool deaf) async {
    // Set self deaf status
  }

  Future<void> setSelfMute(bool mute) async {
    // Set self mute status
  }

  Future<void> setVoiceState({
    bool? selfDeaf,
    bool? selfMute,
  }) async {
    // Set voice state
  }

  void speaking({
    required bool speaking,
    required int delay,
    required int ssrc,
    SpeakingMode mode = SpeakingMode.microphone,
  }) {
    _kernel.shards.forEach((id, shard) {
      final message = ShardMessageBuilder()
        .setOpCode(OpCode.voiceGuildPing)
        .append('speaking', mode.value)
        .append('delay', delay)
        .append('ssrc', ssrc);

      shard.client.send(message.build());
    });
  }

  // Other methods like talk, stopTalking, etc.
}