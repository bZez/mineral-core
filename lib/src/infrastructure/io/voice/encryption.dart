import 'dart:typed_data';
import 'package:mineral/src/infrastructure/io/voice/encryption_mode.dart';
import 'package:opus_dart/opus_dart.dart';

abstract class Encryption {
  factory Encryption.xSalsa20Poly1305() => OpusEncryption();

  Future<Encryption> init();

  Uint8List randomNonce();

  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List key,
  });

  Uint8List decrypt({
    required Uint8List encrypted,
    required Uint8List nonce,
    required Uint8List key,
  });


  factory Encryption.getEncryption(EncryptionMode mode) {
    switch (mode) {
      case EncryptionMode.xSalsa20Poly1305:
      case EncryptionMode.xSalsa20Poly1305Lite:
      case EncryptionMode.xSalsa20Poly1305Suffix:
        return Encryption.xSalsa20Poly1305();

      case EncryptionMode.aeadAesGcm:
      default:
        throw UnimplementedError();
    }
  }
}

final class OpusEncryption implements Encryption {
  @override
  Uint8List decrypt({required Uint8List encrypted, required Uint8List nonce, required Uint8List key}) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  Uint8List encrypt({required Uint8List message, required Uint8List nonce, required Uint8List key}) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }

  @override
  Future<Encryption> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Uint8List randomNonce() {
    // TODO: implement randomNonce
    throw UnimplementedError();
  }
  
}
