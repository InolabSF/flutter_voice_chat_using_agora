import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms/room_tile_view_model.dart';
import 'dart:math';

class RoomTile extends StatelessWidget {
  const RoomTile({ @required this.model, this.onPressed });
  final RoomTileViewModel model;
  final VoidCallback onPressed;

  Widget _speakerImages(BuildContext context) {
    List<String> imageUrls = model.participantImageUrls();
    if (imageUrls.isEmpty) {
      return Container();
    }
    return Container(
      child: Stack(
        children: imageUrls.asMap().entries.map((entry) {
          int index = entry.key;
          String imageUrl = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: 8 + 36 * index.toDouble(), top: 8 + 36 * index.toDouble()),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 60.0,
                width: 60.0,
              ),
            )
          );
        }).toList()
      ),
    );
  }

  Widget _speakersNameList(BuildContext context) {
    List<String> speakerNames = model.participantNames();
    int itemCount = min(speakerNames.length, 4);
    if (itemCount == 0) {
      return Text(
        'Currently this room has no participants'
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: speakerNames.map((e) => Text('$e 💬', style: Theme.of(context).textTheme.headline6)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red[500],
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Text(model.roomTitle, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                FutureBuilder(
                  future: model.populateParticipants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(width: 144, child: this._speakerImages(context)),
                          SizedBox(width: 16.0,),
                          Expanded(child: this._speakersNameList(context))
                        ]
                      );
                    } else {
                      return Center(child: CircularProgressIndicator(),);
                    }
                  },
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
