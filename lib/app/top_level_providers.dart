import 'package:firebase_auth/firebase_auth.dart' as FirAuth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/constants/configs.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/services/agora_service.dart';
import 'package:flutter_voice_chat_using_agora/services/firestore_service.dart';

final firebaseAuthProvider = Provider<FirAuth.FirebaseAuth>((ref) => FirAuth.FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<FirAuth.User>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FirestoreService>((ref) {
  final auth = ref.watch(authStateChangesProvider);

  if (auth.data?.value?.uid != null) {
    return FirestoreService(uid: auth.data?.value?.uid);
  }
  return null;
});

final agoraProvider = Provider<AgoraService>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  if (auth.data?.value?.uid != null) {
    return AgoraService(agoraAppId: Configs.AgoraAppId, uid: auth.data.value.uid.hashCode);
  }
  return null;
});

final userProvider = StreamProvider<User>((ref) {
  final database = ref.watch(databaseProvider);
  return database?.userStream();
});