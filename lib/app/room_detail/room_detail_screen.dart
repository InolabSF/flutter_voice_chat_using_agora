import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/app/home/empty_feed.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/room_detail_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/speaker_tile.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/speaker_tile_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/top_level_providers.dart';
import 'package:flutter_voice_chat_using_agora/models/room.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/routing/app_routes.dart';
import 'package:flutter_voice_chat_using_agora/widgets/dialog_helper.dart';
import 'package:flutter_voice_chat_using_agora/widgets/form_submit_button.dart';
import 'package:flutter_voice_chat_using_agora/widgets/profile_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

AutoDisposeStreamProvider<RoomDetailViewModel> createUsersStreamProvider({ Room room }) {
  return StreamProvider.autoDispose<RoomDetailViewModel>((ref) {
    final database = ref.watch(databaseProvider);
    final agora = ref.watch(agoraProvider);
    final currentUserStream = ref.watch(userProvider);
    if (database != null && agora != null && currentUserStream != null) {
      return currentUserStream.when(
        data: (User currentUser) {
          return database.roomStream(agoraService: agora, room: room, currentUser: currentUser);
        },
        loading: () => const Stream.empty(),
        error: (error, stackTrace) => const Stream.empty()
      );
    }
    return const Stream.empty();
  });
}

class RoomDetailScreen extends ConsumerWidget {

  final Room room;
  final AutoDisposeStreamProvider<RoomDetailViewModel> usersStreamProvider;
  RoomDetailScreen({ @required this.room })
      : usersStreamProvider = createUsersStreamProvider(room: room);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final currentUserStream = watch(userProvider);
    final usersStream = watch(usersStreamProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    int numTilesHorizontal = (screenWidth / 120).floor();
    return Scaffold(
      appBar: AppBar(
        actions: [
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
      body: SafeArea(
        child: usersStream.when(
          data: (model) {
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 16.0,),
                    Text(
                      model.room.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Expanded(
                      child: FutureBuilder<List<User>>(
                        future: model.participants(),
                        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            List<User> users = snapshot.data;
                            return Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: GridView.count(
                                crossAxisCount: numTilesHorizontal,
                                children: List.generate(users.length, (index) {
                                  final user = users[index];
                                  return SpeakerTile(
                                    model: SpeakerTileViewModel(speaker: user)
                                  );
                                }),
                              ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        }
                      )
                    ),
                  ]
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      model.isParticipating() ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: currentUserStream.when(
                              data: (User user) {
                                return IconButton(
                                  icon: user.isMuted ? FaIcon(FontAwesomeIcons.microphone) : FaIcon(FontAwesomeIcons.microphoneSlash),
                                  onPressed: () {
                                    model.toggleMute(!user.isMuted);
                                  }
                                );
                              },
                              loading: () {
                                return Container();
                              },
                              error: (error, stackTrace) {
                                return Container();
                              }
                            )
                          )
                        ],
                      ) : Container(),
                      Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      width: double.infinity,
                      child: FormSubmitButton(
                        key: const Key('join-room-button'),
                        text: model.joinButtonText(),
                        initialLoading: false,
                        onPressed: () async {
                          if (model.isParticipating()) {
                            await model.leaveRoom();
                          } else if (model.isParticipatingInAnotherRoom()) {
                            AwesomeDialog dialog = DialogHelper.leavingParticipatingRoomDialog(context, model);
                            dialog.show();
                            await model.leaveRoom();
                            await model.joinRoom();
                          } else {
                            await model.joinRoom();
                          }
                        }
                      )
                    )],
                  ),
                )
              ]
            );
          },
          loading: () {
            return Center(child: CircularProgressIndicator());
          },
          error: (error, stackTrace) {
            return const EmptyFeed(
              title: 'Something went wrong',
              message: 'Can\'t load users right now',
            );
          }
        ),
      )
    );
  }
}