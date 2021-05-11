import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/constants/configs.dart';

class AgoraService {

  final String agoraAppId;
  final int uid;
  AgoraService({ @required this.agoraAppId, @required this.uid }) {
    _initEngine();
  }

  RtcEngine _engine;
  List<int> remoteUids = [];

  void _initEngine() async {
    _engine = await RtcEngine.createWithConfig(RtcEngineConfig(this.agoraAppId));

    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  Future<void> joinChannel({ String channelId, Function onJoinChannelComplete, Function onLeaveChannelComplete }) async {
    if (_engine == null) {
      _initEngine();
    }
    _engine?.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        onJoinChannelComplete();
      },
      leaveChannel: (RtcStats stats) {
        onLeaveChannelComplete();
      },
      userJoined: (int uid, int elasped) {
        remoteUids.add(uid);
      },
      userOffline: (int uid, UserOfflineReason reason) {
        remoteUids.remove(uid);
      }
    ));
    await _engine.joinChannel(null, channelId, null, uid);
  }

  void leaveChannel() {
    _engine?.leaveChannel();
  }
}