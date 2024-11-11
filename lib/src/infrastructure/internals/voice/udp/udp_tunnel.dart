import 'dart:io';

import 'package:mineral/src/infrastructure/internals/voice/udp/udp_information.dart';

final class UDPTunnel {
  final UdpInformation information;
  late final RawDatagramSocket socket;

  UDPTunnel(this.information);

  Future<void> connect() async {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.listen(print);
  }
}