import 'package:mineral/container.dart';
import 'package:mineral/contracts.dart';
import 'package:mineral/src/api/common/invite/invite.dart';
import 'package:mineral/src/api/common/invite/invite_type.dart';

final class ServerInvite implements Invite {
  DataStoreContract get _datastore => ioc.resolve<DataStoreContract>();

  @override
  final String code;
  @override
  final InviteType type;
  @override
  final int uses;
  @override
  final int maxUses;
  final String? serverId;
  final String? channelId;
  final String? inviterId;
  final String? targetId;

  final int maxAge;
  final bool temporary;
  final DateTime createdAt;
  final DateTime? expiresAt;

  ServerInvite({
    required this.code,
    required this.uses,
    required this.maxUses,
    required this.maxAge,
    required this.temporary,
    required this.createdAt,
    this.type = InviteType.server,
    this.serverId,
    this.channelId,
    this.inviterId,
    this.targetId,
    this.expiresAt,
  });

  @override
  Future<void> delete() async {
    await _datastore.invite.delete(code);
  }
}