import 'package:mineral/src/infrastructure/internals/voice/wss/voice_opcode.dart';

abstract interface class VoiceWssMessage<T> {
  String? get type;

  VoiceOpCode get opCode;

  int? get sequence;

  T get payload;

  Object serialize();
}

final class VoiceWssMessageImpl<T> implements VoiceWssMessage<T> {
  @override
  final String? type;

  @override
  final VoiceOpCode opCode;

  @override
  final int? sequence;

  @override
  final T payload;

  VoiceWssMessageImpl(
      {required this.type,
      required this.opCode,
      required this.sequence,
      required this.payload});

  factory VoiceWssMessageImpl.of(Map<String, dynamic> message) {
    print('Received voice message from VoiceWssMessageImpl.of : $message');
    return VoiceWssMessageImpl(
      type: message['t'],
      opCode:
          VoiceOpCode.values.firstWhere((element) => element.value == message['op']),
      sequence: message['s'],
      payload: message['d']);
  }

  @override
  Object serialize() {
    return {
      't': type,
      'op': opCode.value,
      's': sequence,
      'd': payload,
    };
  }
}
