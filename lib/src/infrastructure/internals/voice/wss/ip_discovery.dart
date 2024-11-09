import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'ip_info.dart';

Future<InternetInfo?> ipDiscovery({
  required int ssrc,
  required InternetAddress address,
  required int port,
}) async {
  const ipReqLength = 74;

  var udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
  var byteData = ByteData(ipReqLength);
  byteData.setUint16(0, 1);
  byteData.setUint16(2, 70);
  byteData.setUint32(4, ssrc);

  for (var i = 0; i < address.rawAddress.length; i++) {
    byteData.setUint8(8 + i, address.rawAddress[i]);
  }
  byteData.setUint16(ipReqLength - 2, port); // port

  var buffer = byteData.buffer.asUint8List();
  var bytesSent = udpSocket.send(buffer, address, port);
  if (bytesSent <= 0) {
    print('Error on UDP Socket: bytes sent = $bytesSent');
    udpSocket.close();
    return null;
  }

  Datagram? datagram;
  await for (final event in udpSocket) {
    if (event == RawSocketEvent.read) {
      datagram = udpSocket.receive();
      break;
    }
  }

  udpSocket.close();

  if (datagram == null) {
    return null;
  }

  final ipData = datagram.data.sublist(8, datagram.data.indexOf(0, 8));
  final extAddress = InternetAddress.tryParse(utf8.decode(ipData));

  final dLength = datagram.data.length;
  final extPort = datagram.data.buffer.asByteData().getUint16(dLength - 2);
  return InternetInfo(extAddress, extPort);
}
