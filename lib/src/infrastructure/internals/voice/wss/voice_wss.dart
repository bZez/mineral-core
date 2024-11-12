import 'dart:convert';

import 'package:mineral/container.dart';
import 'package:mineral/src/api/common/voice/voice_state.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/udp_tunnel.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_controller.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_manager.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/constants/voice_op_code.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/dispatchers/voice_authentication.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/dispatchers/voice_heartbeat.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_message.dart';
import 'package:mineral/src/infrastructure/services/wss/websocket_client.dart';

final class VoiceWss {
  late final String name;
  final String url;
  final VoiceState state;

  late final WebsocketClient client;
  late final VoiceController controller;
  late final VoiceAuthentication authentication;
  late final UDPTunnel udpTunnel;
  late final VoiceHeartbeat heartbeat;

  VoiceWss({required this.url, required this.state}) {
    name = 'voice-${state.serverId}';
    controller = ioc.resolve<VoiceManagerContract>().get(state.serverId);
    authentication = VoiceAuthentication(this, controller.kernel);
    heartbeat = VoiceHeartbeat(this);
  }

  Future<void> init() async {
    client = WebsocketClientImpl(
      name: name,
      url: 'wss://$url?v=8',
      onError: (error) {
        print('error $error');
      },
      onClose: (int? exitCode, String? reason) {
        print('exitCode $exitCode, reason $reason');
        controller.disconnect();

        // close udp tunnel

        udpTunnel.receiver.close();
        udpTunnel.sender.close();
      },
    );

    client.interceptor.message.add((message) async {
      message.content = VoiceMessageImpl.of(jsonDecode(message.originalContent));
      return message;
    });

    client.listen((message) async {
      if (message.content case VoiceMessageImpl(opCode: final code, payload: final payload)) {
        print('received $code $payload');
        switch (code) {
          case VoiceOpCode.hello:
            authentication.identify(payload);
          case VoiceOpCode.ready:
            authentication.selectProtocol(payload);
          case VoiceOpCode.sessionDescription:
            authentication.handleSessionDescription(payload);
          case VoiceOpCode.heartbeat:
            heartbeat.heartbeat();
          case VoiceOpCode.heartbeatAck:
            heartbeat.ack(payload['t']);
          default:
            break;
        }
      }
    });

    await client.connect();
  }
}
