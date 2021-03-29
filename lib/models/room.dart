import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';

class Room {
  final String identifier;
  final String title;
  List<User> speakers = [];
  List<DocumentReference> speakerRefs = [];
  List<User> audience = [];

  Room({ @required this.identifier, @required this.title });

  factory Room.fromMap(Map<String, dynamic> data, String documentId) {
    String title = data['title'] as String;
    List<DocumentReference> speakerRefs = List<DocumentReference>.from(data['speakers']);
    Room room = Room(identifier: documentId, title: title);
    room.speakerRefs = speakerRefs;
    return room;
  }

  Future<void> fetchSpeakers(bool force) async {
    if (this.speakers != null && this.speakers.length == speakerRefs.length && !force) {
      return;
    }

    List<Future> speakerFetches = [];
    for (DocumentReference speakerRef in speakerRefs) {
      speakerFetches.add(Future<DocumentSnapshot>(() async {
        return speakerRef.get();
      }));
    }
    List<DocumentSnapshot> snapshots = List<DocumentSnapshot>.from(await Future.wait(speakerFetches));
    List<User> speakers = snapshots.map((snapshot) {
      if (snapshot.data() != null) {
        return User.fromMap(snapshot.id, snapshot.data());
      }
      return null;
    }).where((element) => element != null).toList();
    this.speakers = speakers;
  }
}
