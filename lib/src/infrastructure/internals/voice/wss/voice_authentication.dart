import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mineral/api.dart';
import 'package:mineral/services.dart';
import 'package:mineral/src/infrastructure/internals/container/ioc_container.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/audio_player.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_opcode.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/discord_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/wss/constants/op_code.dart';
import 'package:mineral/src/infrastructure/internals/wss/dispatchers/shard_authentication.dart';
import 'package:mineral/src/infrastructure/services/logger/logger.dart';

abstract interface class VoiceAuthentication {
  late final Timer heartbeatTimer;
  void setupRequirements();

  void identify(Map<String, dynamic> payload);

  Future<void> connect();

  void reconnect();

  void heartbeat();

  void ack();

  void resume();

  Future<void> ready(Map<String, dynamic> payload);
}

final class VoiceAuthenticationImpl implements VoiceAuthentication {
  final AudioPlayer player;
  @override
  late final Timer heartbeatTimer;

  int? sequence;
  String? sessionId;
  String? resumeUrl;

  VoiceAuthenticationImpl(this.player);

  @override
  void identify(Map<String, dynamic> payload) {
    print('Received identify voice with payload: $payload');
    print(sessionId);
    createHeartbeatTimer(payload['heartbeat_interval']);
    final bot = ioc.resolve<Bot>();

    print('Identifying voice');

    final message = VoiceMessageBuilder()
        .setOpCode(VoiceOpCode.identify)
        .append('server_id', player.controller.serverId)
        .append('user_id', bot.id)
        .append('session_id', sessionId)
        .append('token', player.token);

    player.wss.send(message.build());
  }

  void createHeartbeatTimer(int interval) {
   heartbeatTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      heartbeat();
    });
  }

  @override
  void heartbeat() {
    print('Sending heartbeat voice');
    player.wss.send(jsonEncode({
      'op': 1,
      'd': null,
    }));
  }

  @override
  void ack() {
    ioc.resolve<LoggerContract>().trace('Received heartbeat ack');
  }

  @override
  Future<void> connect() async {
    await player.wss.connect();
  }

  @override
  void reconnect() {
    player.wss.disconnect();
    connect();
  }

  @override
  void resume() {
    final message = ShardMessageBuilder()
        .setOpCode(OpCode.resume)
        //.append('token', shard.kernel.config.token)
        .append('session_id', sessionId)
        .append('seq', sequence);

    player.wss.send(message.build());
  }

  @override
  void setupRequirements() {
    final ShardAuthenticationImpl shard = player.controller.kernel.shards.values.first.authentication as ShardAuthenticationImpl;

    sessionId = shard.sessionId;
  }

  @override
  Future<void> ready(Map<String, dynamic> payload) async {
    print('Received ready voice with payload: $payload');

    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );

    final selectProtocolMessage = VoiceMessageBuilder()
      .setOpCode(VoiceOpCode.selectProtocol)
      .append('protocol', 'udp')
      .append('data', {
        'address': socket.address.address,
        'port': socket.port,
        'mode': 'xsalsa20_poly1305_suffix',
      });

    player.wss.send(selectProtocolMessage.build());
   // socket.send(Uint8List.fromList([0x01, 0x00, 0x00, 0x00]), InternetAddress.tryParse(payload['data']['ip'])!, payload['data']['port']);

    player
      ..socket = socket
      ..ssrc = payload['ssrc']
      ..remoteIp = payload['ip']
      ..remotePort = payload['port'];

    socket.listen((event) {
      print('Received voice packet : $event');
    });


  }
}
