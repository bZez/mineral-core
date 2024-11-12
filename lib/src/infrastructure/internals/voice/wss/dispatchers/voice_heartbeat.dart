import 'dart:async';

import 'package:mineral/src/infrastructure/internals/voice/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss.dart';

import '../constants/voice_op_code.dart';

final class VoiceHeartbeat {
  final VoiceWss voice;
  late final Timer heartbeatTimer;
  int sequence = 0;
  int t = 0;

  VoiceHeartbeat(this.voice);

  void createHeartbeatTimer(int interval) {
    print('createHeartbeatTimer $interval');
    heartbeatTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      print('heartbeatTimer');
      heartbeat();
    });
  }

  void heartbeat() {
    final message = VoiceMessageBuilder()
        .setOpCode(VoiceOpCode.heartbeat)
        .append('seq_ack', sequence)
        .append('t', DateTime.now().millisecondsSinceEpoch);

    voice.client.send(message.build());

    print('heartbeat $sequence $t');
  }

  void ack(int t) {
    sequence++;
    this.t = t;

    print('ack $sequence $t');
  }
}