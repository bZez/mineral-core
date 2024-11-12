import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:mineral/src/infrastructure/io/encryption/encryption.dart';
import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';

final class Aes256GcmEncryption implements Encryption {
  @override
  final EncryptionType type = EncryptionType.aeadAes256GcmRtpsize;
  final Uint8List key;
  final int ssrc;

  Aes256GcmEncryption(this.key, this.ssrc);

  @override
  Future<void> init() async {
    // will be used to transport encryption
  }

  @override
  Future<Uint8List> encrypt(Uint8List data, Uint8List nonce) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);

    final encrypted = await algorithm.encrypt(data, secretKey: secretKey, nonce: nonce);
    final encryptedData = Uint8List.fromList(encrypted.cipherText);

    return encryptedData;
  }

  @override
  Uint8List generateNonce(int length, int seq) {
    final nonce = ByteData(length)
      ..setUint8(0, 0x80)
      ..setUint8(1, 0x78)
      ..setUint16(2, seq)
      ..setUint32(4, seq * 960)
      ..setUint32(8, ssrc);

    return nonce.buffer.asUint8List();
  }

  @override
  Future<String> decrypt(Uint8List data, Uint8List nonce, Uint8List mac) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(key);

    final secretBox = SecretBox(data, nonce: nonce, mac: Mac(mac));
    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return String.fromCharCodes(decrypted);
  }
}
