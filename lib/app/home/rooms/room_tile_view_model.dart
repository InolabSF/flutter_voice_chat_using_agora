import 'package:flutter/foundation.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';

class RoomTileViewModel {

  final Room room;
  final User currentUser;

  String roomTitle = '';

  RoomTileViewModel({ @required this.room, @required this.currentUser }) {
    this.roomTitle = this.room.title;
  }

  List<String> participantImageUrls() {
    User firstSpeaker;
    if (room.speakers.length > 0) {
      firstSpeaker = room.speakers.first;
    }
    User secondSpeaker;
    if (room.speakers.length > 1) {
      secondSpeaker = room.speakers[1];
    }
    List<String> imageUrls = [];
    if (firstSpeaker != null) {
      imageUrls.add(firstSpeaker.imageUrl);
    }
    if (secondSpeaker != null) {
      imageUrls.add(secondSpeaker.imageUrl);
    }
    return imageUrls;
  }

  List<String> participantNames() {
    User firstSpeaker;
    if (room.speakers.length > 0) {
      firstSpeaker = room.speakers.first;
    }
    User secondSpeaker;
    if (room.speakers.length > 1) {
      secondSpeaker = room.speakers[1];
    }
    List<String> names = [];
    if (firstSpeaker != null) {
      names.add(firstSpeaker.displayName);
    }
    if (secondSpeaker != null) {
      names.add(secondSpeaker.displayName);
    }
    if (room.speakers.length > 2) {
      int numAdditionalSpeakers = room.speakers.length - 2;
      if (numAdditionalSpeakers == 1) {
        names.add('+1 speaker');
      } else {
        names.add('+${room.speakers.length - 2} speakers');
      }
    }
    return names;
  }

  Future<void> populateParticipants() async {
    await room.fetchSpeakers(false);
  }
}
