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

  // DAVE protocol

  davePrepareTransition(21),
  daveExecuteTransition(22),
  daveTransitionReady(23),
  davePrepareEpoch(24),
  daveMLSExternalSender(25),
  daveMLSKeyPackage(26),
  daveMLSProposal(27),
  daveMLSCommitWelcome(28),
  daveMLSAnnounceCommitTransition(29),
  daveMLSWelcome(30),
  daveMLSInvalidCommitWelcome(31),

  // todo: search for the missing opcodes https://discord.com/developers/docs/topics/opcodes-and-status-codes#voice
  none(11),
  noneTwo(18),
  noneFor(15),
  noneThree(20),;

  final int value;
  const VoiceOpCode(this.value);
}