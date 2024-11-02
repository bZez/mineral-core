import 'package:mineral/src/infrastructure/internals/container/ioc_container.dart';
import 'package:mineral/src/infrastructure/internals/marshaller/marshaller.dart';
import 'package:mineral/src/infrastructure/internals/packets/listenable_packet.dart';
import 'package:mineral/src/infrastructure/internals/packets/packet_type.dart';
import 'package:mineral/src/infrastructure/internals/voice/audio_player.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_manager.dart';
import 'package:mineral/src/infrastructure/internals/wss/shard_message.dart';
import 'package:mineral/src/infrastructure/services/logger/logger.dart';

final class VoiceServerUpdatePacket implements ListenablePacket {
  @override
  PacketType get packetType => PacketType.voiceServerUpdate;

  final LoggerContract logger;
  final MarshallerContract marshaller;

  VoiceServerUpdatePacket(this.logger, this.marshaller);

  @override
  Future<void> listen(ShardMessage message, DispatchEvent dispatch) async {
    final payload = message.payload;
    print(payload);

    final serverId = payload['guild_id'];
    final token = payload['token'];
    final endpoint = payload['endpoint'];

    final voiceManager = ioc.resolve<VoiceManagerContract>();

    final controller = voiceManager.getControllerOrFail(serverId);

    controller.audioPlayer = await AudioPlayer.init(localPort: 7878, controller: controller, endpoint: endpoint, token: token);

  }
}
