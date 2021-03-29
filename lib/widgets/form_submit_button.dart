import 'package:flutter/material.dart';

class FormSubmitButton extends StatefulWidget {

  final bool initialLoading;
  final Key key;
  final String text;
  final Function onPressed;

  FormSubmitButton({ @required this.key, @required this.text, @required this.onPressed, this.initialLoading = false });

  @override
  _FormSubmitButtonState createState() => _FormSubmitButtonState();
}

class _FormSubmitButtonState extends State<FormSubmitButton> {
  double borderRadius = 4.0;
  bool _loading;

  @override
  void initState() {
    _loading = widget.initialLoading;
    super.initState();
  }

  Widget buildSpinner(BuildContext context) {
    final ThemeData data = Theme.of(context);
    return Theme(
      data: data.copyWith(accentColor: Colors.white70),
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.indigo,
          onPrimary: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
          )
        ),
        child: _loading ? buildSpinner(context) : Text(
          widget.text,
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        onPressed: () async {
          setState(() {
            _loading = !_loading;
          });
          await widget.onPressed();
          setState(() {
            _loading = !_loading;
          });
        }
      ),
    );
  }
}