import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

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
    await _engine.enableAudioVolumeIndication(500, 3, false);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  Future<void> joinChannel({
    String channelId,
    Function onJoinChannelComplete,
    Function onLeaveChannelComplete,
    Function onMuteStatusChanged,
    Function setActiveSpeaker
  }) async {
    if (_engine == null) {
      _initEngine();
    }
    _engine?.setEventHandler(RtcEngineEventHandler(
      activeSpeaker: (uid) {
        if (uid == this.uid) {
          setActiveSpeaker(true);
        } else {
          setActiveSpeaker(false);
        }
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
      remoteAudioStateChanged: (int uid, AudioRemoteState state, AudioRemoteStateReason reason, int elapsed) {
        if (uid == this.uid && reason == AudioRemoteStateReason.LocalMuted) {
          onMuteStatusChanged(true);
        } else if (uid == this.uid && reason == AudioRemoteStateReason.LocalUnmuted) {
          onMuteStatusChanged(false);
        }
      },
      userMuteAudio: (int uid, bool isMuted) {
        if (uid == this.uid) {
          onMuteStatusChanged(isMuted);
        }
      },
    ));
    await _engine.joinChannel(null, channelId, null, uid);
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }
}