import 'dart:ffi';
import 'dart:typed_data';

import 'package:mineral/src/infrastructure/io/encryption/encryption.dart';
import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';
import 'package:opus_dart/opus_bindings.dart';
import 'package:opus_dart/opus_dart.dart';

final class Aes256GcmEncryption implements Encryption {
  @override
  final EncryptionType type = EncryptionType.aeadAes256GcmRtpsize;

  final Uint8List key;
  final Uint8List nonce;

  Aes256GcmEncryption(this.key, this.nonce);

  @override
  Future<void> init() async {
    final lib = await _getOpusLib();
    initOpus(lib);

    print('Opus version: ${getOpusVersion()}');
  }

  @override
  Future<Uint8List> encrypt(String data) async {
    // Encrypt data using AES-256-GCM

    return Uint8List(0);
  }

  @override
  Future<String> decrypt(String data) async {
    // Decrypt data using AES-256-GCM
    return '';
  }

  Future<DynamicLibrary> _getOpusLib() async {
    return DynamicLibrary.open('/usr/local/lib/libopus.so');
  }
}