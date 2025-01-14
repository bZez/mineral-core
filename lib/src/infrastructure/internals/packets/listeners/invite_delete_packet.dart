import 'package:mineral/contracts.dart';
import 'package:mineral/src/domains/events/event.dart';
import 'package:mineral/src/domains/services/container/ioc_container.dart';
import 'package:mineral/src/infrastructure/internals/packets/listenable_packet.dart';
import 'package:mineral/src/infrastructure/internals/packets/packet_type.dart';
import 'package:mineral/src/infrastructure/internals/wss/shard_message.dart';

final class InviteCreatePacket implements ListenablePacket {
  @override
  PacketType get packetType => PacketType.inviteDelete;

  MarshallerContract get _marshaller => ioc.resolve<MarshallerContract>();

  @override
  Future<void> listen(ShardMessage message, DispatchEvent dispatch) async {
    final payload = message.payload;

    final raw = await _marshaller.serializers.invite.normalize(payload);
    final invite = await _marshaller.serializers.invite.serialize(raw);

    dispatch(event: Event.serverInviteCreate, params: [invite]);
  }
}
