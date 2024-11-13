import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mineral/api.dart';
import 'package:mineral/container.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/udp_information.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/udp_tunnel.dart';
import 'package:mineral/src/infrastructure/internals/voice/udp/utils/voice_utils.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/builders/voice_message_builder.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/constants/voice_op_code.dart';
import 'package:mineral/src/infrastructure/internals/voice/wss/voice_wss.dart';
import 'package:mineral/src/infrastructure/internals/wss/dispatchers/shard_authentication.dart';
import 'package:mineral/src/infrastructure/io/encryption/aes_256_gcm_encryption.dart';
import 'package:mineral/src/infrastructure/io/encryption/encryption_type.dart';
import 'package:mineral/src/infrastructure/kernel/kernel.dart';

final class VoiceAuthentication {
  final VoiceWss voice;
  final KernelContract kernel;

  VoiceAuthentication(this.voice, this.kernel);

  Future<void> identify(Map<String, dynamic> payload) async {
    voice.heartbeat.createHeartbeatTimer(payload['heartbeat_interval']);

    final bot = ioc.resolve<Bot>();
    final authentication = kernel.shards.values.first.authentication as ShardAuthenticationImpl;
    final sessionId = authentication.sessionId;

    final message = VoiceMessageBuilder()
        .setOpCode(VoiceOpCode.identify)
        .append('server_id', voice.state.serverId)
        .append('user_id', bot.id.value)
        .append('session_id', sessionId)
        .append('token', voice.state.token);

    await voice.client.send(message.build());
  }

  Future<void> selectProtocol(Map<String, dynamic> payload) async {
    final address = InternetAddress(payload['ip']);
    final infos = await VoiceUtils.getInternetInfo(address: address, port: payload['port'], ssrc: payload['ssrc']);

    voice.udpTunnel = UDPTunnel(
      UdpInformation(
        ip: payload['ip'],
        port: infos!.port,
        mode: EncryptionType.aeadAes256GcmRtpsize,
        ssrc: payload['ssrc'],
      ),
      client: voice,
    );

    final message = VoiceMessageBuilder().setOpCode(VoiceOpCode.selectProtocol).append('protocol', 'udp').append('data', {
      'address': infos.address!.address,
      'port': infos.port,
      'mode': voice.udpTunnel.remoteInformation.mode.value,
    });

    print('selectProtocol ${infos.address!.address} ${infos.port} ${voice.udpTunnel.remoteInformation.mode.value}');

    voice.udpTunnel.connect();
    await voice.client.send(message.build());
  }

  Future<void> connect() async {
    await voice.client.connect();
  }

  void reconnect() {}

  Future<void> handleSessionDescription(Map<String, dynamic> payload) async {
    print('handleSessionDescription $payload');
    final secretKey = Uint8List.fromList((payload['secret_key'] as List).cast<int>());
    voice.udpTunnel.remoteInformation.secretKey = secretKey;
    voice.udpTunnel.encryption = Aes256GcmEncryption(voice.udpTunnel.remoteInformation.secretKey, voice.udpTunnel.remoteInformation.ssrc);
  }
}
