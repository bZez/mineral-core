import 'dart:async';

import 'package:mineral/src/api/common/invite/invite_type.dart';
import 'package:mineral/src/api/server/server_invite.dart';
import 'package:mineral/src/domains/contracts/marshaller/marshaller.dart';
import 'package:mineral/src/domains/services/container/ioc_container.dart';
import 'package:mineral/src/infrastructure/internals/marshaller/types/serializer.dart';

final class ServerInviteSerializer implements SerializerContract<ServerInvite> {
  MarshallerContract get _marshaller => ioc.resolve<MarshallerContract>();

  @override
  Future<Map<String, dynamic>> normalize(Map<String, dynamic> json) async {
    final payload = {
      'code': json['code'],
      'server_id': json['server_id'],
      'channel_id': json['channel_id'],
      'inviter_id': json['inviter_id'],
      'target_id': json['target_id'],
      'uses': json['uses'],
      'max_uses': json['max_uses'],
      'max_age': json['max_age'],
      'temporary': json['temporary'],
      'created_at': json['created_at'],
      'expires_at': json['expires_at'],
      'type': json['type'],
    };

    final cacheKey = _marshaller.cacheKey.invite(json['server_id'], json['id']);
    await _marshaller.cache?.put(cacheKey, payload);

    return payload;
  }

  @override
  ServerInvite serialize(Map<String, dynamic> json) {
    return ServerInvite(
      code: json['code'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.tryParse(json['expires_at']),
      inviterId: json['inviter_id'],
      maxAge: json['max_age'],
      maxUses: json['max_uses'],
      serverId: json['server_id'],
      channelId: json['channel_id'],
      targetId: json['target_id'],
      temporary: json['temporary'],
      type: InviteType.values.firstWhere((e) => e.toString() == json['type']),
      uses: json['uses'],
    );
  }

  @override
  Map<String, dynamic> deserialize(ServerInvite invite) {
    return {
      'code': invite.code,
      'server_id': invite.serverId,
      'channel_id': invite.channelId,
      'inviter_id': invite.inviterId,
      'target_id': invite.targetId,
      'uses': invite.uses,
      'max_uses': invite.maxUses,
      'max_age': invite.maxAge,
      'temporary': invite.temporary,
      'created_at': invite.createdAt,
      'expires_at': invite.expiresAt,
    };
  }
}
