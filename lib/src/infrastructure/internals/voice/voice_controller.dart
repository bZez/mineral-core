import 'package:mineral/api.dart';
import 'package:mineral/container.dart';
import 'package:mineral/src/api/common/voice/voice_state.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_manager.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/constants/voice_op_code.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/discord_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/wss/constants/op_code.dart';
import 'package:mineral/src/infrastructure/kernel/kernel.dart';

final class VoiceController {
  final Snowflake serverId;
  final Snowflake channelId;
  final KernelContract kernel;

  late final VoiceState state;
  late final VoiceWss client;

  VoiceController(this.kernel, {required this.serverId, required this.channelId}) {
    ioc.resolve<VoiceManagerContract>().add(this);
  }

  /// Used to connect to the voice channel.
  ///
  /// This method will send a voice state update packet to the Discord API.
  Future<void> connect() async {
    final shard = kernel.shards.values.first;

    final message = ShardMessageBuilder()
        .setOpCode(OpCode.voiceStateUpdate)
        .append('guild_id', serverId.value)
        .append('channel_id', channelId.value)
        .append('self_mute', false)
        .append('self_deaf', false);

    await shard.client.send(message.build());
  }

  /// Used to disconnect from the voice channel.
  ///
  /// This method will send a voice state update packet to the Discord API.
  Future<void> disconnect() async {
    final shard = kernel.shards.values.first;

    final message = ShardMessageBuilder()
        .setOpCode(OpCode.voiceStateUpdate)
        .append('guild_id', serverId.value)
        .append('channel_id', null)
        .append('self_mute', false)
        .append('self_deaf', false);

    await shard.client.send(message.build());
    client.heartbeat.heartbeatTimer.cancel();
  }

  /// Used to send speaking status to the voice channel.
  Future<void> speak({ int delay = 0 }) async {
    final message = VoiceMessageBuilder()
        .setOpCode(VoiceOpCode.speaking)
        .append('speaking', 5)
        .append('delay', delay)
        .append('ssrc', client.udpTunnel.remoteInformation.ssrc);

    await client.client.send(message.build());

    print('send speaking status to wss');
    await client.udpTunnel.test();
  }
}
