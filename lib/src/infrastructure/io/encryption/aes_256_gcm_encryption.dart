import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:mineral/src/infrastructure/io/encryption/encryption.dart';
import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';
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
    // will be used to transport encryption
  }

  @override
  Future<Uint8List> encrypt(File file) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);

    final data = await file.readAsBytes();
    final encrypted = await algorithm.encrypt(data, secretKey: secretKey, nonce: nonce);
    final encryptedData = Uint8List.fromList(encrypted.cipherText);

    return encryptedData;
  }

  @override
  Future<String> decrypt(String data) async {
    return '';
  }

  Future<DynamicLibrary> _getOpusLib() async {
    return DynamicLibrary.open('/usr/local/lib/libopus.so');
  } // not really used
}