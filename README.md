# flutter_voice_chat_using_agora

A Flutter app that allows users to have voice chats

## Getting Started

This project is a starting point for a Flutter application to share voice chat in an app.

The application uses [Flutter Riverpod](https://pub.dev/packages/riverpod) for its state management.

After cloning this repo, there are a few things you have to do to make it work.

0. You can optionally change the app identifier.  Currently the app identifer is "com.dentsu-innovations.flutter_voice_chat_using_agora".  You can do a string search in the project and replace it with your choice.  For iOS, the app identifer is "com.dentsu-innovations.flutter-voice-chat-using_agora" as no underscores are allowed.
1. You must create a project in Firebase.  Please refer to [the official guide for Flutter](https://firebase.google.com/docs/flutter/setup) and download two files, google-services.json and GoogleService-Info.plist and place them in appropriate places of this project.
2. After creating the Firebase project, you must use Firestore and create data model in backend.  Please create collection "rooms" and put at least one room.  There should be a key "speakers" with type array of references, and value should be empty.  Another key is title and value is string, you can put whatever string you want to describe the room.  Please also create "users" collection and you don't need to put anything there.  "users" collection will be populated automatically as people sign up.  The collections could look as follows: ![Firestore collections](https://github.com/InolabSF/flutter_voice_chat_using_agora/blob/master/firestore_collections_example.png?raw=true)
4. You must create an Agora project.  You can do so from [Agora's console](https://console.agora.io/).
5. After creating the Agora project, you must modify lib/constants/configs.dart to include the Agora App Id
6. When you first use the app, an onboarding screen will come up.  After that you will see a login gate.  Create new account.  You can modify your information once you are in the app.
7. Now you should be able to share voice using multiple devices!  It is best to use devices as simulator/emulators seem to be able to hear, but not pass sounds to Agora.
