
import 'package:flutter/material.dart';

class User {
  String identifier;
  String handle;
  String displayName;
  int numFollowers = 0;
  List<User> followers = [];
  int numFollowing = 0;
  List<User> following = [];
  String description;
  String imageUrl;
  bool isMuted = false;

  User({ @required this.identifier });

  factory User.fromMap(String documentId, Map<String, dynamic> map) {
    User user = User(identifier: documentId);
    user.handle = map['handle'] as String;
    user.displayName = map['displayName'] as String;
    user.numFollowers = map['numFollowers'] as int;
    user.numFollowing = map['numFollowing'] as int;
    user.description = map['description'] as String;
    user.imageUrl = map['imageUrl'] as String;
    user.isMuted = map['isMuted'] as bool ?? false;
    return user;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;
}