import 'package:firebase_auth/firebase_auth.dart' as FirAuth;
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms_feed.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms_feed_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/profile/user_detail_screen.dart';
import 'package:flutter_voice_chat_using_agora/app/profile/user_detail_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/room_detail_screen.dart';
import 'package:flutter_voice_chat_using_agora/app/sign_in/email_password_sign_in_screen.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/services/firestore_service.dart';

class AppRoutes {
  static const emailPasswordSignInScreen = '/email-password-sign';
  static const roomsFeed = '/rooms-feed';
  static const roomDetail = '/room-detail';
  static const profile = '/profile';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, FirAuth.FirebaseAuth firebaseAuth, FirestoreService database) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.emailPasswordSignInScreen:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInScreen.withFirebase(firebaseAuth, onSignedIn: args),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.roomsFeed:
        return MaterialPageRoute<dynamic>(
          builder: (_) => RoomsFeed(
            model: RoomsFeedViewModel(auth: firebaseAuth, database: database),
            onSignOut: args,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.roomDetail:
        Room room = (args as Map<String, Object>)['room'];
        User user = (args as Map<String, Object>)['currentUser'];
        return MaterialPageRoute<dynamic>(
          builder: (_) => RoomDetailScreen(room: room, currentUser: user),
          settings: settings,
          fullscreenDialog: true
        );
      case AppRoutes.profile:
        String uid = (args as Map<String, Object>)['uid'];
        User user = User(identifier: uid);
        return MaterialPageRoute<dynamic>(
          builder: (_) {
            return UserDetailScreen(initialModel: UserDetailViewModel(database: database, user: user));
          }
        );
      default:
        return null;
    }
  }
}
