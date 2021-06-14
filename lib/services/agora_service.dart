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

  Future<void> joinChannel({
    String channelId,
    Function onJoinChannelComplete,
    Function onLeaveChannelComplete,
    Function onMuteStatusChanged,
  }) async {
    if (_engine == null) {
      _initEngine();
    }
    _engine?.setEventHandler(RtcEngineEventHandler(
      activeSpeaker: (uid) {
        // TODO: UI indication of who is speaking
      },
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
      },
      userMuteAudio: (int uid, bool isMuted) {
        if (uid == this.uid) {
          onMuteStatusChanged(isMuted);
        }
      },
    ));
    await _engine.joinChannel("<Room token to come here>", channelId, null, uid);
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }
}