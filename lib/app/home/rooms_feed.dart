import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/widgets/form_submit_button.dart';
import 'package:flutter_voice_chat_using_agora/widgets/dialog_helper.dart';
import 'package:flutter_voice_chat_using_agora/app/home/empty_feed.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms/room_tile.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms/room_tile_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms_feed_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/app/top_level_providers.dart';
import 'package:flutter_voice_chat_using_agora/constants/strings.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/routing/app_routes.dart';
import 'package:flutter_voice_chat_using_agora/widgets/profile_button.dart';

final roomsTileModelStreamProvider = StreamProvider.autoDispose<List<RoomTileViewModel>>((ref) {
  final database = ref.watch(databaseProvider);
  if (database != null) {
    return database.roomsStream().map((rooms) => rooms.map((room) => RoomTileViewModel(room: room)).toList());
  }
  return const Stream.empty();
});

class RoomsFeed extends ConsumerWidget {

  final RoomsFeedViewModel model;
  final VoidCallback onSignOut;

  RoomsFeed({
    @required this.model,
    @required this.onSignOut
  });

  final TextEditingController _createdRoomNameController = TextEditingController();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final roomsTileViewModelStream = watch(roomsTileModelStreamProvider);
    final currentUserStream = watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appName),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await model.signOut();
              this.onSignOut();
            }
          ),
          currentUserStream.when(
            data: (User user) {
              return ProfileButton(
                userImagePath: user.imageUrl,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.profile,
                    arguments: { 'uid': user.identifier },
                  );
                },
              );
            },
            loading: () {
              return Container();
            },
            error: (error, stackTrace) {
              return Container();
            }
          )
        ],
      ),
      body: Stack(
        children: [
          roomsTileViewModelStream.when(
            data: (List<RoomTileViewModel> items) {
              return items.isEmpty ? Container() : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  RoomTileViewModel item = items[index];
                  return RoomTile(
                    model: item,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.roomDetail,
                        arguments: { 'room': item.room },
                      );
                    },
                  );
                },
              );
            },
            loading: () {
              return Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              return const EmptyFeed(
                title: 'Something went wrong',
                message: 'Can\'t load items right now',
              );
            }
          ),
          model.isLoading ? Center(child: CircularProgressIndicator(),) : Container(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              width: double.infinity,
              child: FormSubmitButton(
                key: const Key('create-room-button'),
                text: model.createRoomButtonText(),
                initialLoading: false,
                onPressed: () async {
                  AwesomeDialog dialog = DialogHelper.createdRoomNameDialog(context, _createdRoomNameController, model);
                  await dialog.show();
                  String roomName = _createdRoomNameController.text;
                  if (model.currentUserIsParticipatingInARoom()) {
                    AwesomeDialog leavingCurrentRoomDialog = DialogHelper.leavingParticipatingRoomDialogUponRoomCreate(context, model);
                    leavingCurrentRoomDialog.show();
                  }
                  Room room = await model.createRoom(roomName);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.roomDetail,
                    arguments: { 'room': room },
                  );
                }
              )
            )
          )
        ]
      ),
    );
  }
}