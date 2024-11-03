import 'dart:convert';

import 'package:mineral/src/infrastructure/internals/voice/wss/voice_opcode.dart';

final class VoiceMessageBuilder {
  VoiceOpCode? _code;
  Map<String, dynamic>? _payload;

  VoiceMessageBuilder();

  VoiceMessageBuilder setOpCode(VoiceOpCode code) {
    _code = code;
    return this;
  }

  VoiceMessageBuilder append(String key, dynamic payload) {
    _payload ??= {};
    _payload![key] = payload;

    return this;
  }

  String build() {
    return jsonEncode({
      'op': _code!.value,
      'd': _payload,
    });
  }
}
