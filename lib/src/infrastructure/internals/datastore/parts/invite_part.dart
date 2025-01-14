import 'dart:async';

import 'package:mineral/contracts.dart';
import 'package:mineral/services.dart';
import 'package:mineral/src/api/common/invite/invite.dart';
import 'package:mineral/src/domains/services/container/ioc_container.dart';

final class InvitePart implements InvitePartConstract {
  MarshallerContract get _marshaller => ioc.resolve<MarshallerContract>();

  DataStoreContract get _dataStore => ioc.resolve<DataStoreContract>();

  HttpClientStatus get status => _dataStore.client.status;

  @override
  Future<Invite> create(String serverId, { String? channelId, String? targetId, int? maxAge, int? maxUses, bool temporary = false, bool unique = false, String? reason}) async {
    final completer = Completer<Invite>();

    final result = await _dataStore.requestBucket
        .run<Map<String, dynamic>>(() => _dataStore.client.post('/guilds/$serverId/invites', body: {
          'channel_id': channelId,
          'target_id': targetId,
          'max_age': maxAge,
          'max_uses': maxUses,
          'temporary': temporary,
          'unique': unique,
          'reason': reason,
        }));

    final raw = await _marshaller.serializers.invite.normalize(result);
    final invite = await _marshaller.serializers.invite.serialize(raw);
    completer.complete(invite);
    return completer.future;
  }

  @override
  Future<void> delete(String code) async {
    await _dataStore.client.delete('/invites/$code');
  }

  @override
  Future<Invite> get(String code, bool force) async {
    final completer = Completer<Invite>();

    final result = await _dataStore.requestBucket
        .run<Map<String, dynamic>>(() => _dataStore.client.get('/invites/$code'));

    final raw = await _marshaller.serializers.invite.normalize(result);
    final invite = await _marshaller.serializers.invite.serialize(raw);
    completer.complete(invite);
    return completer.future;
  }
}