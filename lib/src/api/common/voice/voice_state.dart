import 'package:mineral/api.dart';

final class VoiceState {
  final Snowflake serverId;
  final Snowflake channelId;
  final String token;
  final bool deaf;
  final bool mute;

  VoiceState({
    required this.serverId,
    required this.channelId,
    required this.token,
    required this.deaf,
    required this.mute,
  });
}