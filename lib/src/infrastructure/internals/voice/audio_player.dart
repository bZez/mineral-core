import 'dart:io';

import 'package:mineral/api.dart';
import 'package:mineral/container.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_controller.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_opcode.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/io/voice/encryption.dart';
import 'package:mineral/src/infrastructure/io/voice/encryption_mode.dart';
import 'package:mineral/src/infrastructure/services/wss/websocket_client.dart';

final class AudioPlayer {
  final VoiceController controller;
  final Encryption encryption;
  final EncryptionMode encryptionMode;
  final String token;
  String? sessionId;


  final RawDatagramSocket socket;
  final String endpoint;
  final int localPort;
  final WebsocketClientImpl wss;

  bool stopped = false;

  AudioPlayer._({
    required this.controller,
    required this.encryption,
    required this.encryptionMode,
    required this.socket,
    required this.endpoint,
    required this.localPort,
    required this.wss,
    required this.token,
  });

  static Future<AudioPlayer> init({
    required String endpoint,
    required int localPort,
    required VoiceController controller,
    required String token,
    EncryptionMode encryptionMode = EncryptionMode.xSalsa20Poly1305,
  }) async {
    endpoint = endpoint.replaceFirst('wss://', '').replaceAll(':443', '');
    final encryption = await Encryption.getEncryption(encryptionMode).init();

    final socket = await RawDatagramSocket.bind(
      InternetAddress.tryParse('127.0.0.1'),
      localPort,
    );

    final wss = WebsocketClientImpl(
      url: 'wss://$endpoint?v=8',
      name: 'voice',
      onOpen: (message) async {
        print('Connected to voice server');
      },
    );

    wss.listen((message) {
      print('Received message : ${message.content}');
    });

    await wss.connect();

    return AudioPlayer._(
      controller: controller,
      encryption: encryption,
      encryptionMode: encryptionMode,
      socket: socket,
      endpoint: endpoint,
      localPort: localPort,
      wss: wss,
      token: token,
    );
  }

  Future<void> _identify() async {
    final bot = ioc.resolve<Bot>();

    final message = VoiceMessageBuilder()
        .setOpCode(VoiceOpCode.identify)
        .append('server_id', controller.serverId) // todo send identify payload
        .append('user_id', bot.id)
        .append('session_id', sessionId);

    // https://discord.com/developers/docs/topics/voice-connections#connecting-to-voice
    // https://github.com/gabrielpacheco23/discord-voice-extension/blob/master/bots/voice/voice_connection.dart

    await wss.send(message.build());
  }

  Future<void> play(File file) async {
    controller.speaking(speaking: true, delay: 5, ssrc: 1);

  }
}
