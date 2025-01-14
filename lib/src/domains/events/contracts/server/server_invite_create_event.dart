import 'dart:async';

import 'package:mineral/api.dart';
import 'package:mineral/events.dart';
import 'package:mineral/src/api/common/invite/invite.dart';
import 'package:mineral/src/domains/events/types/listenable_event.dart';

typedef ServerInviteCreateHandler = FutureOr<void> Function(Invite invite);

abstract class ServerInviteCreateEvent implements ListenableEvent {
  @override
  Event get event => Event.serverInviteCreate;

  @override
  String? customId;

  FutureOr<void> handle(Server server, Invite invite);
}