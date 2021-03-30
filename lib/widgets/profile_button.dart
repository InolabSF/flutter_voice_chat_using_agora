import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {

  final String userImagePath;
  final Function onPressed;

  ProfileButton({ this.userImagePath, this.onPressed });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 40.0,
          width: 40.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: userImagePath == null ? Image.asset('resources/profile.png') : Image.network(userImagePath),
          ),
        ),
      ),
    );
  }
}