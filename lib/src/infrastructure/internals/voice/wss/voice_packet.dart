import 'dart:typed_data';
import 'dart:math' as math;

// final seq = math.Random().nextInt((1 << 16) - 1);

class VoicePacket {
  final List<int> audioBytes;
  final int ssrc;
  late final ByteData data;

  static const _rtpHeaderSize = 12;
  static const _nonceSize = 24;
  // static int seq = math.Random().nextInt((1 << 16) - 1);
  static late int seq;
  static late int timestamp;

  static void resetMetadata() {
    seq = -1;
    timestamp = -1;
  }

  static void incrementMetadata() {
    seq += 1;
    timestamp = seq * 960;

    if (seq >= 65535) {
      seq = 0;
    }
    if (timestamp >= 4294967295) {
      timestamp = 0;
    }
  }

  static Uint8List generateNonce(int ssrc) {
    var nonce = ByteData(_nonceSize);
    nonce.setUint8(0, 0x80);
    nonce.setUint8(1, 0x78);
    nonce.setUint16(2, seq);
    nonce.setUint32(4, timestamp); //      see *timestamp*
    nonce.setUint32(8, ssrc);
    for (var i = 0; i < _rtpHeaderSize; i++) {
      nonce.setUint8(12 + i, 0);
    }
    return nonce.buffer.asUint8List();
  }

  static int simpleNonce() => math.Random().nextInt(1 << 32);

  VoicePacket.lite(
    this.audioBytes, {
    required this.ssrc,
    required int nonce,
  }) {
    data = ByteData(audioBytes.length + _rtpHeaderSize + 4);
    data.setUint8(0, 0x80);
    data.setUint8(1, 0x78);
    data.setUint16(2, seq);
    data.setUint32(4, 960); //      see *timestamp*
    data.setUint32(8, ssrc);
    for (var i = 0; i < audioBytes.length; i++) {
      data.setUint8(12 + i, audioBytes[i]);
    }
    data.setUint32(12 + audioBytes.length, nonce);
  }

  VoicePacket(this.audioBytes, {required this.ssrc}) {
    data = ByteData(audioBytes.length + _rtpHeaderSize);
    final header = ByteData.sublistView(data, 0, _rtpHeaderSize);
    final encAudio =
        ByteData.sublistView(data, _rtpHeaderSize, data.lengthInBytes);

    header.setUint8(0, 0x80);
    header.setUint8(1, 0x78);
    header.setUint16(2, seq);
    header.setUint32(4, timestamp); //   see *timestamp*
    header.setUint32(8, ssrc);
    // for (var i = 0; i < audioBytes.length; i++) {
    for (var i = 0; i < encAudio.lengthInBytes; i++) {
      // data.setUint8(12 + i, audioBytes[i]);
      encAudio.setUint8(i, audioBytes[i]);
    }
  }

  Uint8List get buffer => data.buffer.asUint8List();
}

//  *timestamp*:
// One frame corresponds to 20ms
// For 1 second, there will be 1000ms / 20ms = 50 frames

// Audio RTP packet timestamp incremental value = 48kHz / 50 = 48000Hz / 50 = 960.