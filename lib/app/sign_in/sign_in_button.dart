
import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final Key key;
  final String text;
  final Function onPressed;

  SignInButton({
    this.key,
    this.text,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            shadowColor: Colors.black87,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            )
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 20.0, color: Colors.white)
          ),
          onPressed: this.onPressed
        ),
      )
    );
  }
}