import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms/room_tile_view_model.dart';
import 'package:flutter_voice_chat_using_agora/services/firestore_service.dart';

class RoomsFeedViewModel with ChangeNotifier {
  RoomsFeedViewModel({ @required this.auth, @required this.database });
  final FirebaseAuth auth;
  final FirestoreService database;
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

  Stream<List<RoomTileViewModel>> roomTileViewModelsStream() {
    return database.roomsStream().map((rooms) {
      return rooms.map((room) => RoomTileViewModel(room: room)).toList();
    });
  }
}
