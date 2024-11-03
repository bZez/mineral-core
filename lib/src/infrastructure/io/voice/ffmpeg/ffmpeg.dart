import 'dart:io';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:chunked_stream/chunked_stream.dart';

abstract class Ffmpeg {
//   static String convert(String inputPath, {String? outputPath}) =>
//       mp3ToOpus(inputPath, output: outputPath);

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

// String mp3ToOpus(String input, {String? output}) {
//   // var input = '/home/gabriel/Documents/dartprojs/gdp/cavalo';
//   var outputPath = output;
//   if (output == null) {
//     outputPath = input.replaceAll('mp3', 'ogg');
//   }

//   // '-i', '$input.mp3', '-c:a', 'libopus', '$input.opus'
//   Process.runSync('ffmpeg', [
//     '-i',
//     '$input',
//     '-ar',
//     '48k',
//     '-ac',
//     '2',
//     '-c:a',
//     'libopus',
//     '-b:a',
//     '96k',
//     // '-f',
//     // 's16le',
//     // '-loglevel',
//     // 'quiet',
//     // 'pipe:1',
//     // '-vbr',
//     // 'on',
//     // '-compression_level',
//     // '10',
//     // '-frame_duration',
//     // ' 20',
//     // '-application',
//     // 'voip',
//     '$outputPath',
//   ]);

//   return outputPath!;
// }

// void main() async {
//   final path = '/home/gabriel/Documents/dartprojs/gdp/audios/cavalo.mp3';
//   // var opusAudio = Ffmpeg.convert(path);

//   // var bytes = <int>[];
//   var stdout = (await Ffmpeg.chunkedStdout(path, 10));
//   var chunked = [];
//   await for (var chunk in stdout) {
//     // var data = [];
//     // chunked.add(chunk);
//     print(chunk);
//   }

//   // stdout.forEach(print);

//   // File('$path.copy.mp3').writeAsBytesSync(await stdout.first);
// }