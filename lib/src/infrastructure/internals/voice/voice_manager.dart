import 'package:mineral/api.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_controller.dart';

abstract class VoiceManagerContract {
  final Map<Snowflake, VoiceController> _controllers = {};

  VoiceController get(Snowflake serverId) {
    return _controllers[serverId]!;
  }

  void add(VoiceController controller) {
    _controllers[controller.serverId] = controller;
  }

  void remove(Snowflake serverId) {
    _controllers.remove(serverId);
  }
}

final class VoiceManagerImpl implements VoiceManagerContract {
  @override
  final Map<Snowflake, VoiceController> _controllers = {};

  @override
  VoiceController get(Snowflake serverId) {
    return _controllers[serverId]!;
  }

  @override
  void add(VoiceController controller) {
    _controllers[controller.serverId] = controller;
  }

  @override
  void remove(Snowflake serverId) {
    _controllers.remove(serverId);
  }
}