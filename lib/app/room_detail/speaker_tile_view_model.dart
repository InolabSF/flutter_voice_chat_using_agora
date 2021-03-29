import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';

class SpeakerTileViewModel {

  final User speaker;
  SpeakerTileViewModel({ @required this.speaker });

  String imageUrl() {
    return speaker.imageUrl;
  }

  String displayName() {
    return speaker.displayName;
  }

  bool isMuted() {
    return speaker.isMuted;
  }
}