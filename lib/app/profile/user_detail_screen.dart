import 'dart:io';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_voice_chat_using_agora/app/home/empty_feed.dart';
import 'package:flutter_voice_chat_using_agora/app/profile/user_detail_view_model.dart';
import 'package:flutter_voice_chat_using_agora/models/user.dart';
import 'package:flutter_voice_chat_using_agora/app/top_level_providers.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _nameTxt = TextEditingController();
  final TextEditingController _descriptionTxt = TextEditingController();
  final AutoDisposeStreamProvider<UserDetailViewModel> userStreamProvider;
  final picker = ImagePicker();
  UserDetailScreen({ @required this.initialModel })
    : userStreamProvider = createUserStreamProvider(model: initialModel);

  Future _getImage(UserDetailViewModel model) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    await model.updateUserProfileImage(File(pickedFile.path));
  }

  Widget _profilePhoto(BuildContext context, UserDetailViewModel model, User currentUser) {
    return GestureDetector(
      onTap: () async {
        if (model.user == currentUser) {
          final progress = ProgressHUD.of(context);
          progress.show();
          await _getImage(model);
          progress.dismiss();
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 16.0),
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: model.userImageUrl() == null ? AssetImage('resources/profile.png') : NetworkImage(model.userImageUrl()),
            fit: BoxFit.cover
          ),
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }

  Widget _nameWidget(BuildContext context, UserDetailViewModel model, User currentUser) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: TextField(
        enabled: currentUser == model.user,
        controller: _nameTxt,
        style: Theme.of(context).textTheme.headline4,
        textAlign: TextAlign.left,
        onEditingComplete: () {
          model.updateUserDisplayName(_nameTxt.text);
        },
      ),
    );
  }

  Widget _emailWidget(BuildContext context, UserDetailViewModel model) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Text(
        model.userEmail(),
        style: Theme.of(context).textTheme.bodyText1,
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

  Widget _description(BuildContext context, UserDetailViewModel model, User currentUser) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: TextField(
        autofocus: false,
        enabled: currentUser == model.user,
        controller: _descriptionTxt,
        decoration: InputDecoration(
          hintText: 'Describe yourself'
        ),
        onEditingComplete: () {
          model.updateUserDescription(_descriptionTxt.text);
        },
      )
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    Future<User> currentUserFuture = watch(userProvider.last);
    final userStream = watch(userStreamProvider);
    return ProgressHUD(
      child: Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<User>(
          future: currentUserFuture,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              User currentUser = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: userStream.when(
                  data: (UserDetailViewModel viewModel) {
                    _descriptionTxt.text = viewModel.userDescription();
                    _nameTxt.text = viewModel.userDisplayName();
                    return [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _profilePhoto(context, viewModel, currentUser)
                      ),
                      _nameWidget(context, viewModel, currentUser),
                      SizedBox(height: 16.0),
                      _emailWidget(context, viewModel),
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
              );
            }
            return Center(child: CircularProgressIndicator(),);
          },
        ),
      ),
    );
  }
}