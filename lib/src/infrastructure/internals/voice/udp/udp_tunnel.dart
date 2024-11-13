import 'dart:io';
import 'dart:typed_data';

import 'package:mineral/src/infrastructure/internals/voice/udp/udp_information.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/utils/voice_packet.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/utils/voice_utils.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss.dart';
import 'package:mineral/src/infrastructure/io/encryption/aes_256_gcm_encryption.dart';
import 'package:udp/udp.dart';

final class UDPTunnel {
  final UdpInformation remoteInformation;
  late final UDP receiver;
  late final UDP sender;
  late final Aes256GcmEncryption encryption;
  late final VoiceWss client;

  UDPTunnel(this.remoteInformation, { required this.client });

  Future<void> connect() async {
    sender = await UDP.bind(Endpoint.any(port: Port(remoteInformation.port)));

    sender.asStream().listen((datagram) async {
      if (datagram == null) {
        return;
      }

      final data = datagram.data;
      final nonce = data.sublist(0, 12);
      final encrypted = data.sublist(12, data.length - 16);
      final mac = data.sublist(data.length - 16);
    // todo: decrypt data
    });
  }

  Future<void> send(List<int> data) async {
    final nonce = encryption.generateNonce(12, VoicePacket.seq);
    final seq = ByteData(2)..setUint16(0, VoicePacket.seq);
    final encryptedData = await encryption.encrypt(Uint8List.fromList(data), nonce);

    print('send data to udp -> ${encryptedData.length} bytes, seq: ${VoicePacket.seq}, nonce: $nonce');

    // get the timestamp in 4 bytes
    final timestamp = ByteData(4)..setUint32(0, VoicePacket.timestamp);
    final ssrc = ByteData(4)..setUint32(0, remoteInformation.ssrc);

    final packet = Uint8List.fromList([...[0x80], ...[0x78], ...seq.buffer.asUint8List(), ...timestamp.buffer.asUint8List(), ...ssrc.buffer.asUint8List(), ...encryptedData]);

    await sender.send(packet, Endpoint.multicast(InternetAddress(remoteInformation.ip), port: Port(remoteInformation.port)));
  }

  Future<void> test() async {
    final file = File('test.mp3');
    final data = VoiceUtils.chunkedStdout(file.path, 960);
    VoicePacket.resetMetadata();

    await for (final chunk in data) {
      VoicePacket.incrementMetadata();
      client.controller.speak();

      await send(chunk);
      await Future.delayed(const Duration(milliseconds: 20));
    }

    print('Finished');
  }
}