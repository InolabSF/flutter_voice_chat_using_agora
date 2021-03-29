import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Utils {
  static void showExceptionAlertDialog({
    BuildContext context,
    String title,
    String message
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Dismiss'))
        ],
      )
    );
  }

  static Future<bool> showAlertDialog({
    @required BuildContext context,
    @required String title,
    @required String content,
    String cancelActionText,
    @required String defaultActionText,
  }) async {
    if (kIsWeb || !Platform.isIOS) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                child: Text(cancelActionText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            TextButton(
              child: Text(defaultActionText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          if (cancelActionText != null)
            CupertinoDialogAction(
              child: Text(cancelActionText),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          CupertinoDialogAction(
            child: Text(defaultActionText),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  static String followersText(int numFollowers) {
    if (numFollowers == 1) {
      return '$numFollowers follower';
    }
    return '$numFollowers followers';
  }

  static String followingText(int numFollowing) {
    if (numFollowing == 1) {
      return '$numFollowing following';
    }
    return '$numFollowing followings';
  }
}