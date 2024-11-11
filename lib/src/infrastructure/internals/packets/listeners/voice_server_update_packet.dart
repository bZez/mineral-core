import 'package:mineral/container.dart';
import 'package:mineral/src/api/common/snowflake.dart';
import 'package:mineral/src/api/common/voice/voice_state.dart';
import 'package:mineral/src/infrastructure/internals/marshaller/marshaller.dart';
import 'package:mineral/src/infrastructure/internals/packets/listenable_packet.dart';
import 'package:mineral/src/infrastructure/internals/packets/packet_type.dart';
import 'package:mineral/src/infrastructure/internals/voice/voice_manager.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss.dart';
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
    print('payload $payload');
    final serverId = Snowflake(payload['guild_id']);
    final endpoint = payload['endpoint'];
    final token = payload['token'];

    final controller = ioc.resolve<VoiceManagerContract>().get(serverId);
    final state = VoiceState(serverId: serverId, channelId: controller.channelId, token: token, deaf: false, mute: false);
    controller.state = state;

    final wss = VoiceWss(url: endpoint, state: controller.state);

    controller.client = wss;

    await wss.init();
  }
}
