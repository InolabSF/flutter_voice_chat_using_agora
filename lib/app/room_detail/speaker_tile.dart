import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/speaker_tile_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/top_level_providers.dart';

class SpeakerTile extends ConsumerWidget {

  final SpeakerTileViewModel model;
  SpeakerTile({ @required this.model });

  Widget _muteIndicator(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.white,
        child: Icon(Icons.mic_off_rounded)
      ),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return StreamBuilder<SpeakerTileViewModel>(
      stream: watch(databaseProvider).participantStream(user: model.speaker),
      builder: (BuildContext context, AsyncSnapshot<SpeakerTileViewModel> snapshot) {
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.none) {
          return Icon(Icons.error_outline);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        SpeakerTileViewModel model = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      model.imageUrl(),
                      height: 60.0,
                      width: 60.0,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: model.isMuted() ? _muteIndicator(context) : Container(),
                )
              ],
            ),
            SizedBox(height: 8.0,),
            Text(model.displayName(), style: TextStyle(fontWeight: FontWeight.bold),)
          ],
        );
      }
    );
  }
}