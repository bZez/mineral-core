import 'package:mineral/api.dart';
import 'package:mineral/services.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_controller.dart';
import 'package:mineral/src/infrastructure/internals/wss/shard.dart';

abstract class VoiceManagerContract {
  final Map<Snowflake, VoiceController> _controllers = {};

  void addController(VoiceController controller);
  void removeController(VoiceController controller);
  void removeAllControllers();
  void connectAll();
  void disconnectAll();
  VoiceController? getController(Snowflake serverId);
  VoiceController getControllerOrFail(Snowflake serverId);
}

final class VoiceManager implements VoiceManagerContract {
  @override
  final Map<Snowflake, VoiceController> _controllers = {};

  final MarshallerContract _marshaller;

  final Map<int, Shard> _shards = {};

  VoiceManager(this._marshaller);

  @override
  void addController(VoiceController controller) {
    _controllers.putIfAbsent(controller.serverId, () => controller);
  }

  @override
  void removeController(VoiceController controller) {
    _controllers.remove(controller.serverId);
  }

  @override
  void removeAllControllers() {
    _controllers.clear();
  }

  @override
  void connectAll() {
    for (final controller in _controllers.values) {
      controller.connect();
    }
  }

  @override
  void disconnectAll() {
    for (final controller in _controllers.values) {
      controller.disconnect();
    }
  }

  @override
  VoiceController? getController(Snowflake serverId) {
    return _controllers[serverId];
  }

  @override
  VoiceController getControllerOrFail(Snowflake serverId) {
    return _controllers[serverId]!;
  }
}