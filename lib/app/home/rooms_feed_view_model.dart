import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as FirAuth;
import 'package:flutter/foundation.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:meta/meta.dart';
import 'package:flutter_voice_chat_using_agora/services/firestore_service.dart';

class RoomsFeedViewModel with ChangeNotifier {
  RoomsFeedViewModel({ @required this.auth, @required this.database, @required this.user });
  final FirAuth.FirebaseAuth auth;
  final FirestoreService database;
  final User user;
  bool isLoading = false;
  dynamic error;

  Future<void> _signOut() async {
    try {
      isLoading = true;
      notifyListeners();
      await auth.signOut();
      error = null;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _signOut();
  }

  String createRoomButtonText() {
    return 'Create room';
  }

  String roomTitleText() {
    return 'Room title';
  }

  String closeButtonText() {
    return 'Set & close';
  }

  Future<Room> createRoom(String roomName) async {
    Room room = await database.createRoom(currentUser: user, roomName: roomName);
    return room;
  }

  bool currentUserIsParticipatingInARoom() {
    return user.participatingRoomReference != null;
  }

  String leavingCurrentlyJoinedRoomTitle() {
    return 'Leaving current room';
  }

  String leavingCurrentlyJoinedRoomDescription() {
    return 'By creating a room, you will leave the currently joined room.';
  }
}
