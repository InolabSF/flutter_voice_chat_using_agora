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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: userImagePath == null ? AssetImage('resources/profile.png') : NetworkImage(userImagePath),
              fit: BoxFit.contain
            ),
          ),
        ),
      ),
    );
  }
}