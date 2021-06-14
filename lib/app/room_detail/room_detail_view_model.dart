import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/services/agora_service.dart';
import 'package:flutter_voice_chat_using_agora/services/firestore_service.dart';

class RoomDetailViewModel {
  final Room room;
  final User currentUser;
  final FirestoreService database;
  final AgoraService agora;
  RoomDetailViewModel({ @required this.room, @required this.currentUser, @required this.database, @required this.agora });

  Future<List<User>> participants() async {
    await room.fetchSpeakers(false);
    return room.speakers;
  }

  bool isParticipating() {
    if (this.currentUser == null) {
      return false;
    }
    return room.speakerRefs.map((ref) => ref.id).contains(currentUser.identifier);
  }

  bool isParticipatingInAnotherRoom() {
    return !isParticipating() && currentUser.participatingRoomReference != null;
  }

  String joinButtonText() {
    if (isParticipating()) {
      return 'Leave room';
    }
    return 'Join room';
  }

  leaveRoom() async {
    await agora.leaveChannel();
  }

  joinRoom() async {
    await [Permission.microphone, Permission.camera].request();
    agora.joinChannel(
      channelId: room.identifier,
      onJoinChannelComplete: () {
        database.addSpeaker(room: room, speaker: currentUser);
      },
      onLeaveChannelComplete: () {
        database.removeSpeaker(room: room, speaker: currentUser);
      },
      onMuteStatusChanged: (bool isMuted) {
        database.setMuteStatus(
          speaker: currentUser,
          isMuted: isMuted
        );
      }
    );
  }

  void toggleMute(bool muted) {
    agora.toggleMute(muted);
  }

  String leavingCurrentlyJoinedRoomTitle() {
    return 'Leaving current room';
  }

  String leavingCurrentlyJoinedRoomDescription() {
    return 'By joining this room, you will leave the currently joined room.';
  }
}