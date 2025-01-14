import 'package:mineral/container.dart';
import 'package:mineral/contracts.dart';
import 'package:mineral/src/api/common/invite/invite_type.dart';

class Invite {
  DataStoreContract get _datastore => ioc.resolve<DataStoreContract>();

  final String code;
  final InviteType type;
  final int uses;
  final int maxUses;

  Invite({
    required this.code,
    this.uses = 0,
    this.maxUses = 0,
    this.type = InviteType.server,
  });

  Future<void> delete() async {
    await _datastore.invite.delete(code);
  }
}