enum VoiceDisconnectError {
  unknownOpCode(4001, 'Unknown opcode'),
  failedDecode(4002, 'Failed to decode payload'),
  notAuthenticated(4003, 'Not authenticated'),
  authenticationFailed(4004, 'Authentication failed'),
  alreadyAuthenticated(4005, 'Already authenticated'),
  sessionNoLongerValid(4006, 'Session no longer valid'),
  sessionTimeout(4009, 'Session timeout'),
  serverNotFound(4011, 'Server not found'),
  unknownProtocol(4012, 'Unknown protocol'),
  disconnected(4014, 'Disconnected'),
  voiceServerCrashed(4015, 'Voice server crashed'),
  unknownEncryptionMode(4016, 'Unknown encryption mode');

  final int code;
  final String message;

  const VoiceDisconnectError(this.code, this.message);
}