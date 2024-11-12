import 'dart:io';
import 'dart:typed_data';

import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';

abstract class Encryption {
  final EncryptionType type = EncryptionType.none;

  Future<void> init();

  Future<Uint8List> encrypt(Uint8List file, Uint8List nonce);

  Future<String> decrypt(Uint8List data, Uint8List nonce, Uint8List mac);

  Uint8List generateNonce(int length, int seq);
}