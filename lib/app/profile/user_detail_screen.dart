import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/app/home/empty_feed.dart';
import 'package:flutter_voice_chat_using_agora/app/profile/user_detail_view_model.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/app/top_level_providers.dart';

AutoDisposeStreamProvider<UserDetailViewModel> createUserStreamProvider({ UserDetailViewModel model }) {
  return StreamProvider.autoDispose<UserDetailViewModel>((ref) {
    final database = ref.watch(databaseProvider);
    if (database != null) {
      return database.userStream(uid: model.userIdentifier()).map((user) => UserDetailViewModel(database: database, user: user));
    }
    return const Stream.empty();
  });
}

class UserDetailScreen extends ConsumerWidget {
  final UserDetailViewModel initialModel;
  final TextEditingController _txt = TextEditingController();
  final AutoDisposeStreamProvider<UserDetailViewModel> userStreamProvider;
  UserDetailScreen({ @required this.initialModel })
    : userStreamProvider = createUserStreamProvider(model: initialModel);

  Widget _profilePhoto(BuildContext context, UserDetailViewModel model) {
    return Container(
      padding: EdgeInsets.only(left: 16.0),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: model.userImageUrl() == null ? AssetImage('path/the_image.png') : NetworkImage(model.userImageUrl()),
          fit: BoxFit.cover
        ),
        borderRadius: BorderRadius.circular(32.0),
      ),
    );
  }

  Widget _nameWidget(BuildContext context, UserDetailViewModel model) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Text(
        model.userDisplayName(),
        style: Theme.of(context).textTheme.headline4,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _handleWidget(BuildContext context, UserDetailViewModel model) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Text(
        model.userHandle(),
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _numFollowsRow(BuildContext context, UserDetailViewModel model) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(model.followersText(), style: Theme.of(context).textTheme.headline5),
          SizedBox(width: 16.0,),
          Text(model.followingText(), style: Theme.of(context).textTheme.headline5),
        ],
      ),
    );
  }

  Widget _description(BuildContext context, UserDetailViewModel model, Future<User> currentUserFuture) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: FutureBuilder<User>(
        future: currentUserFuture,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            User currentUser = snapshot.data;
            return TextField(
              autofocus: false,
              enabled: currentUser == model.user,
              controller: _txt,
              onEditingComplete: () {
                model.updateUserDescription(_txt.text);
              },
            );
          }
          return TextField(
            autofocus: false,
            enabled: false,
            controller: _txt,
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    Future<User> currentUser = watch(userProvider.last);
    final userStream = watch(userStreamProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: userStream.when(
          data: (UserDetailViewModel viewModel) {
            _txt.text = viewModel.userDescription();
            return [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: _profilePhoto(context, viewModel)
              ),
              _nameWidget(context, viewModel),
              _handleWidget(context, viewModel),
              SizedBox(height: 16.0,),
              _numFollowsRow(context, viewModel),
              _description(context, viewModel, currentUser)
            ];
          },
          loading: () {
            return [ Center(child: CircularProgressIndicator(),) ];
          },
          error: (error, stackTrace) {
            return [
              EmptyFeed(
                message: 'Failed to load user',
              )
            ];
          }
        )
      ),
    );
  }
}