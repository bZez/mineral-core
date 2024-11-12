import 'dart:io';
import 'dart:typed_data';

import 'package:mineral/src/infrastructure/internals/voice/udp/udp_information.dart';
import 'package:mineral/src/infrastructure/io/encryption/aes_256_gcm_encryption.dart';
import 'package:udp/udp.dart';

class UDPTunnel {
  final UdpInformation remoteInformation;
  late final UDP receiver;
  late final UDP sender;
  late final Aes256GcmEncryption encryption;

  UDPTunnel(this.remoteInformation);

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
    final nonce = encryption.generateNonce(12, 0);
    final encryptedData = await encryption.encrypt(Uint8List.fromList(data), nonce);

    // get the timestamp in 4 bytes
    final timestamp = ByteData(4)..setUint32(0, 0);
    final ssrc = ByteData(4)..setUint32(0, remoteInformation.ssrc);

    final packet = Uint8List.fromList([...[0x80], ...[0x78], ...[0x0, 0x0], ...timestamp.buffer.asUint8List(), ...ssrc.buffer.asUint8List(), ...encryptedData]);

    await sender.send(packet, Endpoint.multicast(InternetAddress(remoteInformation.ip), port: Port(remoteInformation.port)));
  }

  Future<void> test() async {
    final file = File('test.mp3');
    final data = await file.readAsBytes();


    // use opus encoder and send data
    print('sending data');
    await send(data);
    print('sent data');
  }
}