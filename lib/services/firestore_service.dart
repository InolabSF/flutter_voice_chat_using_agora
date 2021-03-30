import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirAuth;
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/room_detail_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/speaker_tile_view_model.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/services/agora_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

enum FollowType {
  followers,
  following
}

class FirestoreService {
  FirestoreService({@required this.uid})
      : assert(uid != null, 'Cannot create FirestoreDatabase with null uid');
  final String uid;

  final _service = FirebaseFirestore.instance;

  static Future<void> createUser(FirAuth.UserCredential userCredential) async {
    FirAuth.User user = userCredential.user;
    String email = user.email;
    String displayName = user.email.split('@')[0];
    await FirebaseFirestore.instance.collection('/users/').doc(user.uid).set({
      'description': null,
      'displayName': displayName,
      'email': email,
      'imageUrl': null,
      'numFollowers': 0,
      'numFollowing': 0
    });
  }

  Stream<User> userStream({ String uid }) {
    if (uid == null) {
      uid = this.uid;
    }
    return _service.collection('/users/').doc(uid).snapshots().map((snapshot) => User.fromMap(snapshot.id, snapshot.data()));
  }

  void updateUserDisplayName({ String uid, String displayName }) {
    _service.collection('/users/').doc(uid).update({
      'displayName': displayName
    });
  }

  void updateUserDescription({ String uid, String description }) {
    _service.collection('/users/').doc(uid).update({
      'description': description
    });
  }

  void updateUserProfileImageUrl({ String uid, String userProfileImageUrl }) {
    _service.collection('/users/').doc(uid).update({
      'imageUrl': userProfileImageUrl
    });
  }

  Future<List<User>> getFollows(FollowType type) async {
    List<DocumentReference> followerRefs = await _service.doc('/users/$uid/${type.toString()}').get() as List<DocumentReference>;
    List<DocumentSnapshot> followers = await Future.wait(followerRefs.map((followerRef) => followerRef.get()));

    return followers.map((snapshot) {
      return User.fromMap(snapshot.id, snapshot.data());
    }).toList();
  }

  Stream<List<Room>> roomsStream() {
    return _service.collection('rooms').snapshots().map((snapshot) => snapshot.docs.map((doc) => Room.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<RoomDetailViewModel> roomStream({ AgoraService agoraService, Room room, User currentUser }) {
    return _service.doc('/rooms/${room.identifier}').snapshots()
        .map((snapshot) => Room.fromMap(snapshot.data(), snapshot.id))
        .map((room) => RoomDetailViewModel(room: room, currentUser: currentUser, database: this, agora: agoraService));
  }

  Stream<SpeakerTileViewModel> participantStream({ User user }) {
    return _service.doc('/users/${user.identifier}').snapshots()
        .map((snapshot) => User.fromMap(snapshot.id, snapshot.data()))
        .map((speaker) => SpeakerTileViewModel(speaker: speaker));
  }

  void removeSpeaker({ Room room, User speaker }) {
    _service.doc('/rooms/${room.identifier}').update({
      'speakers': FieldValue.arrayRemove([_service.collection('users').doc(speaker.identifier)])
    });
  }

  void addSpeaker({ Room room, User speaker }) {
    _service.doc('/rooms/${room.identifier}').update({
      'speakers': FieldValue.arrayUnion([_service.collection('users').doc(speaker.identifier)])
    });
  }
}
