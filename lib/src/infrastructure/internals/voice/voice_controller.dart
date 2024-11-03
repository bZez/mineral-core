import 'dart:io';

import 'package:mineral/api.dart';
import 'package:mineral/src/infrastructure/internals/voice/speaking_mode.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/audio_player.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/discord_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/wss/constants/op_code.dart';
import 'package:mineral/src/infrastructure/kernel/kernel.dart';

final class VoiceController {
  final Snowflake serverId;
  final Snowflake channelId;
  final bool selfDeaf;
  final bool selfMute;
  final KernelContract kernel;
  late AudioPlayer audioPlayer;

  VoiceController(this.kernel, {
    required this.serverId,
    required this.channelId,
    required this.selfDeaf,
    required this.selfMute,
  });

  Future<void> connect() async {
    print('Connecting to voice channel : $channelId...');
    print(kernel.shards.length);

    kernel.shards.forEach((id, shard) {
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
    print('File from voice controller : ${file.path}');
    await audioPlayer.play(file);
  }

  Future<void> disconnect() async {
    print('Disconnecting from voice channel : $channelId...');
    print(kernel.shards.length);

    kernel.shards.forEach((id, shard) {
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
    SpeakingMode mode = SpeakingMode.microphone,
  }) {
    print('Sending speaking message to voice server...');
/*    final message = VoiceMessageBuilder()
      .setOpCode(VoiceOpCode.speaking)
      .append('speaking', speaking)
      .append('delay', delay)
      .append('ssrc', audioPlayer.ssrc)
      .append('mode', mode.value);

    audioPlayer.wss.send(message.build());*/

    final file = File('test.mp3');

    if (!file.existsSync()) {
      print('File does not exist');
      // create file
      final newFile = File('test.test');
      newFile.createSync();
      return;
    }

    print('Playing audio file...');
    print(file.path);

    // encrypt audio file

    play(file);
  }

  // Other methods like talk, stopTalking, etc.
}