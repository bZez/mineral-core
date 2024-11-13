import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/utils/internet_info.dart';

final class VoiceUtils {
  static Future<InternetInfo?> getInternetInfo({
    required int ssrc,
    required InternetAddress address,
    required int port,
  }) async {
    const ipReqLength = 74;
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);

    final byteData = ByteData(ipReqLength)
      ..setUint16(0, 1)
      ..setUint16(2, 70)
      ..setUint32(4, ssrc);

    for (var i = 0; i < address.rawAddress.length; i++) {
      byteData.setUint8(8 + i, address.rawAddress[i]);
    }
    byteData.setUint16(ipReqLength - 2, port); // port

    final buffer = byteData.buffer.asUint8List();
    final bytesSent = socket.send(buffer, address, port);
    if (bytesSent <= 0) {
      print('Error on UDP Socket: bytes sent = $bytesSent');
      socket.close();
      return null;
    }

    Datagram? datagram;
    await for (final event in socket) {
      if (event == RawSocketEvent.read) {
        datagram = socket.receive();
        break;
      }
    }

    socket.close();

    if (datagram == null) {
      return null;
    }

    final ipData = datagram.data.sublist(8, datagram.data.indexOf(0, 8));
    final extAddress = InternetAddress.tryParse(utf8.decode(ipData));

    final dLength = datagram.data.length;
    final extPort = datagram.data.buffer.asByteData().getUint16(dLength - 2);
    return InternetInfo(extAddress, extPort);
  }

    static Stream<Uint8List> chunkedStdout(String input, int size) async* {
    final args = [
      '-i',
      '$input',
      '-ar',
      '48k',
      '-ac',
      '2',
      '-c:a',
      'libopus',
      '-b:a',
      '96k',
      '-f',
      's16le',
      '-loglevel',
      'quiet',
      'pipe:1',
    ];

    final process = await Process.start('ffmpeg', args);
    final reader = ChunkedStreamReader(bufferChunkedStream(process.stdout));
    try {
      while (true) {
        final chunk = await reader.readChunk(size);
        // print(chunk);
        yield Uint8List.fromList(chunk);

        if (chunk.length < size) {
          break;
        }
      }
    } finally {
      reader.cancel();
    }
  }
}
