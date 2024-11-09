import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mineral/src/infrastructure/internals/voice/speaking_mode.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_controller.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_authentication.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_opcode.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_packet.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss_message.dart';
import 'package:mineral/src/infrastructure/internals/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/io/voice/encryption.dart';
import 'package:mineral/src/infrastructure/io/voice/encryption_mode.dart';
import 'package:mineral/src/infrastructure/io/voice/ffmpeg/ffmpeg.dart';
import 'package:mineral/src/infrastructure/services/wss/websocket_client.dart';

final class AudioPlayer {
  final VoiceController controller;
  final Encryption encryption;
  final EncryptionMode encryptionMode;
  final String token;
  late final List<int> secretKey;
  late final String mediaSessionId;
  String? sessionId;
  late final VoiceAuthentication authentication;
  late final int ssrc;

  late final RawDatagramSocket socket;
  final String endpoint;
  late final String remoteIp;
  late final int remotePort;
  final WebsocketClientImpl wss;

  bool stopped = false;

  AudioPlayer._({
    required this.controller,
    required this.encryption,
    required this.encryptionMode,
    required this.endpoint,
    required this.wss,
    required this.token,
  }) {
    authentication = VoiceAuthenticationImpl(this);
  }

  static Future<AudioPlayer> init({
    required String endpoint,
    required int localPort,
    required VoiceController controller,
    required String token,
    EncryptionMode encryptionMode = EncryptionMode.xSalsa20Poly1305Suffix,
  }) async {
    endpoint = endpoint.replaceFirst('wss://', '').replaceAll(':443', '');
    final encryption = await Encryption.getEncryption(encryptionMode).init();

    final wss = WebsocketClientImpl(
      url: 'wss://$endpoint?v=8',
      name: 'voice',
      onOpen: (message) async {
        print('Connected to voice server ${message.content}');
        if (message.content case VoiceWssMessage(payload: final payload)) {
          print('Received voice message open : $payload');
        }
      },
      onClose: (exitCode, reason) {
        controller.disconnect();
        controller.audioPlayer.authentication.heartbeatTimer.cancel();

        print('Disconnected from voice server with exit code $exitCode, reason : $reason');
      },
      onError: (error) {
        print('Error on voice server : $error');
      },
    );

    wss.interceptor.message.add((message) async {
      print('Received voice message : ${message.content}');
      message.content = VoiceWssMessageImpl.of(jsonDecode(message.originalContent));
      return message;
    });

    return AudioPlayer._(
      controller: controller,
      encryption: encryption,
      encryptionMode: encryptionMode,
      endpoint: endpoint,
      wss: wss,
      token: token,
    );
  }

  Future<void> connect() async {
    authentication.setupRequirements();

    wss.listen((message) {
      if (message.content case VoiceWssMessage(opCode: final code, payload: final payload)) {
        print('Received voice message : $payload');
        switch (code) {
          case VoiceOpCode.hello:
            authentication.identify(payload);
          case VoiceOpCode.heartbeatAck:
            authentication.ack();
          case VoiceOpCode.heartbeat:
            authentication.heartbeat();
          case VoiceOpCode.sessionDescription:
            secretKey = List.from(payload['secret_key']);
            mediaSessionId = payload['media_session_id'];
          case VoiceOpCode.ready:
            authentication.ready(payload);
          case VoiceOpCode.clientConnect:
            print('Client connected to voice server');

          default:
            print('Unknown op code: $code');

            // Unknown op code ! OpCode.heartbeat
            print(message.originalContent);
        }
      }
    });

    await wss.connect();
  }

  Future<void> play(File file) async {
    print('Playing audio file from audio player : ${file.path}');
    final encryption = await Encryption.getEncryption(encryptionMode).init();

    final chunkSize = 960;
    final audioStream = Ffmpeg.chunkedStdout(file.path, chunkSize);
    VoicePacket.resetMetadata();
    final message = VoiceMessageBuilder().setOpCode(VoiceOpCode.speaking).append('speaking', SpeakingMode.microphone.value).append('delay', 0).append('ssrc', ssrc);

    await wss.send(message.build());
    final nonce = VoicePacket.generateNonce(ssrc);

    await for (final chunk in audioStream) {
      if (stopped) {
        break;
      }

      VoicePacket.incrementMetadata();

      final data = Uint8List.fromList(chunk);
      final key = Uint8List.fromList(secretKey);
      final encryptedData = encryption.encrypt(key: key, message: data, nonce: nonce);

      final voicePacket = VoicePacket(encryptedData, ssrc: ssrc);

      print('Sending speaking message to voice server: $remoteIp:$remotePort');

      final test = socket.send(voicePacket.buffer, InternetAddress(remoteIp), remotePort);
      print('Sent voice packet to voice server : $test');
      await Future.delayed(Duration(milliseconds: 20));
    }

    print('Audio file played');
  }
}
