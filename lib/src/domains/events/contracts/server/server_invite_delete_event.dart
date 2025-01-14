import 'dart:async';

import 'package:mineral/api.dart';
import 'package:mineral/events.dart';
import 'package:mineral/src/api/common/invite/invite.dart';
import 'package:mineral/src/domains/events/types/listenable_event.dart';

typedef ServerInviteDeleteHandler = FutureOr<void> Function(Invite invite);

abstract class ServerInviteDeleteEvent implements ListenableEvent {
  @override
  Event get event => Event.serverInviteDelete;

  @override
  String? customId;

  FutureOr<void> handle(Server server, Invite? invite);
}