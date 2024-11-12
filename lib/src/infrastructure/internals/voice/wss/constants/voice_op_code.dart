enum VoiceOpCode {
  identify(0),
  selectProtocol(1),
  ready(2),
  heartbeat(3),
  sessionDescription(4),
  speaking(5),
  heartbeatAck(6),
  resume(7),
  hello(8),
  resumed(9),
  clientConnect(11),
  clientDisconnect(13),
  unknown(-1);

  final int value;

  const VoiceOpCode(this.value);
}