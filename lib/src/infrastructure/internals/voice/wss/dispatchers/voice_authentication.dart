import 'dart:async';

import 'package:mineral/api.dart';
import 'package:mineral/container.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/constants/voice_op_code.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss.dart';
import 'package:mineral/src/infrastructure/internals/wss/dispatchers/shard_authentication.dart';
import 'package:mineral/src/infrastructure/kernel/kernel.dart';

final class VoiceAuthentication {
  final VoiceWss voice;
  final KernelContract kernel;
  late final Timer heartbeatTimer;

  VoiceAuthentication(this.voice, this.kernel);

  Future<void> identify(Map<String, dynamic> payload) async {
    createHeartbeatTimer(payload['heartbeat_interval']);

    final bot = ioc.resolve<Bot>();
    final authentication = kernel.shards.values.first.authentication as ShardAuthenticationImpl;
    final sessionId = authentication.sessionId;

    final message = VoiceMessageBuilder()
    .setOpCode(VoiceOpCode.identify)
    .append('server_id', voice.state.serverId)
    .append('user_id', bot.id.value)
    .append('session_id', sessionId)
    .append('token', voice.state.token);

    await voice.client.send(message.build());
  }

  void createHeartbeatTimer(int interval) {
    heartbeatTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      heartbeat();
    });
  }

  void heartbeat() {
    final message = VoiceMessageBuilder()
    .setOpCode(VoiceOpCode.heartbeat)
    .append('d', DateTime.now().millisecondsSinceEpoch);

    voice.client.send(message.build());
  }

  Future<void> connect() async {
    await voice.client.connect();
  }

  void reconnect() {

  }
}