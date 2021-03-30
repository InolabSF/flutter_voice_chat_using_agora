import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/app/utils/utils.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/services/firestore_service.dart';

class UserDetailViewModel {
  UserDetailViewModel({ @required this.database, @required this.user });
  final FirestoreService database;
  final User user;

  String userIdentifier() {
    return user.identifier;
  }

  String userImageUrl() {
    return user.imageUrl;
  }

  String userDisplayName() {
    return user.displayName;
  }

  String userEmail() {
    return user.email;
  }

  String followersText() {
    return Utils.followersText(user.numFollowers);
  }

  String followingText() {
    return Utils.followingText(user.numFollowers);
  }

  String userDescription() {
    return user.description;
  }

  void updateUserDisplayName(String newDisplayName) {
    database.updateUserDisplayName(uid: user.identifier, displayName: newDisplayName);
  }

  void updateUserDescription(String newDescription) {
    database.updateUserDescription(uid: user.identifier, description: newDescription);
  }
}
