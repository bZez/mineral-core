import 'dart:io';
import 'dart:typed_data';

import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';

abstract class Encryption {
  final EncryptionType type = EncryptionType.none;

  Future<void> init();

  Future<Uint8List> encrypt(File file);

  Future<String> decrypt(String data);
}