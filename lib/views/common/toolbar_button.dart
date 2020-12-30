import 'package:flutter/material.dart';

class SBToolbarButton extends StatelessWidget {
  final void Function() onPress;
  final String text;
  SBToolbarButton(this.text, this.onPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      child: TextButton(
        onPressed: () {
          this.onPress();
        },
        child: Container(
          child: Text(this.text),
          margin: EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}
