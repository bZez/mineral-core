import 'dart:typed_data';

import 'package:mineral/src/api/common/snowflake.dart';
import 'package:mineral/src/infrastructure/internals/marshaller/marshaller.dart';
import 'package:mineral/src/infrastructure/internals/packets/listenable_packet.dart';
import 'package:mineral/src/infrastructure/internals/packets/packet_type.dart';
import 'package:mineral/src/infrastructure/internals/wss/shard_message.dart';
import 'package:mineral/src/infrastructure/io/encryption/aes_256_gcm_encryption.dart';
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
    final serverId = Snowflake(payload['guild_id']);

    final encyption = Aes256GcmEncryption(Uint8List(0), Uint8List(0));
    await encyption.init();
  }
}
