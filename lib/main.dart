import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final database = context.read(databaseProvider);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => Consumer(
          builder: (context, watch, _) {
            final didCompleteOnboarding = watch(onboardingViewModelProvider.state);
            return didCompleteOnboarding ? SignInScreen() : OnboardingScreen();
          },
        ),
        signedInBuilder: (_) => RoomsFeed(
          model: RoomsFeedViewModel(auth: firebaseAuth),
          onSignOut: () {},
        ),
      ),
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings, firebaseAuth, database),
    );
  }
}
