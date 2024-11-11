import 'package:mineral/src/infrastructure/internals/voice/wss/constants/voice_op_code.dart';

abstract interface class VoiceMessage<T> {
  String? get type;

  VoiceOpCode get opCode;

  int? get sequence;

  T get payload;

  Object serialize();
}

final class VoiceMessageImpl<T> implements VoiceMessage<T> {
  @override
  final String? type;

  @override
  final VoiceOpCode opCode;

  @override
  final int? sequence;

  @override
  final T payload;

  VoiceMessageImpl(
      {required this.type,
      required this.opCode,
      required this.sequence,
      required this.payload});

  factory VoiceMessageImpl.of(Map<String, dynamic> message) => VoiceMessageImpl(
      type: message['t'],
      opCode:
          VoiceOpCode.values.firstWhere((element) => element.value == message['op']),
      sequence: message['s'],
      payload: message['d']);

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
