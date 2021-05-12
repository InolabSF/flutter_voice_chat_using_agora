import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice_chat_using_agora/app/home/rooms_feed_view_model.dart';
import 'package:flutter_voice_chat_using_agora/app/room_detail/room_detail_view_model.dart';
import 'package:flutter_voice_chat_using_agora/constants/strings.dart';

class DialogHelper {
  static AwesomeDialog createdRoomNameDialog(BuildContext context, TextEditingController controller, RoomsFeedViewModel model) {
    var dialog;
    dialog = AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.QUESTION,
      keyboardAware: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Material(
              elevation: 0,
              color: Colors.blueGrey.withAlpha(40),
              child: TextFormField(
                autofocus: true,
                minLines: 1,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: model.roomTitleText(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AnimatedButton(
              text: model.closeButtonText(),
              pressEvent: () {
                dialog.dissmiss();
              }
            )
          ],
        ),
      ),
    );
    return dialog;
  }

  static AwesomeDialog leavingParticipatingRoomDialog(BuildContext context, RoomDetailViewModel model) {
    var dialog;
    dialog = AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.INFO,
      keyboardAware: true,
      borderSide: BorderSide(color: Colors.green, width: 2),
      buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      title: model.leavingCurrentlyJoinedRoomTitle(),
      desc: model.leavingCurrentlyJoinedRoomDescription(),
      showCloseIcon: true,
      btnCancelOnPress: () {},
      btnCancelText: Strings.dismiss,
      btnOkOnPress: () {},
    );
    return dialog;
  }

  static AwesomeDialog leavingParticipatingRoomDialogUponRoomCreate(BuildContext context, RoomsFeedViewModel model) {
    var dialog;
    dialog = AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      dialogType: DialogType.INFO,
      keyboardAware: true,
      borderSide: BorderSide(color: Colors.green, width: 2),
      buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      title: model.leavingCurrentlyJoinedRoomTitle(),
      desc: model.leavingCurrentlyJoinedRoomDescription(),
      showCloseIcon: true,
      btnCancelOnPress: () {},
      btnCancelText: Strings.dismiss,
      btnOkOnPress: () {},
    );
    return dialog;
  }
}