import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_voice_chat_using_agora/routing/app_routes.dart';
import 'package:flutter_voice_chat_using_agora/services/shared_preferences_service.dart';
import 'app/auth_widget.dart';
import 'app/home/rooms_feed.dart';
import 'app/home/rooms_feed_view_model.dart';
import 'app/onboarding/onboarding_screen.dart';
import 'app/onboarding/onboarding_view_model.dart';
import 'app/top_level_providers.dart';
import 'app/sign_in/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesServiceProvider.overrideWithValue(
          SharedPreferencesService(sharedPreferences),
        ),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => Consumer(
          builder: (context, watch, _) {
            final bool onboardingComplete = watch(onboardingViewModelProvider);
            return onboardingComplete ? SignInScreen() : OnboardingScreen();
          },
        ),
        signedInBuilder: (_) => Consumer(
          builder: (context, watch, _) {
            final database = watch(databaseProvider);
            final currentUserStream = watch(userProvider);
            return currentUserStream.when(
              data: (User user) {
                return RoomsFeed(
                  model: RoomsFeedViewModel(auth: firebaseAuth, database: database, user: user),
                  onSignOut: () {},
                );
              },
              loading: () {
                return Container();
              },
              error: (error, stackTrace) {
                return Container();
              }
            );
          },
        ),
      ),
      onGenerateRoute: (settings) {
        final database = context.read(databaseProvider);
        return AppRouter.onGenerateRoute(settings, firebaseAuth, database);
      },
    );
  }
}
