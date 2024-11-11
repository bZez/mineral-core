import 'dart:typed_data';

import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';

final class UdpInformation {
  final String ip;
  final int port;
  final int ssrc;
  final EncryptionType mode;
  final Uint8List secretKey;

  UdpInformation({
    required this.ip,
    required this.port,
    required this.mode,
    required this.secretKey,
    required this.ssrc,
  });
}