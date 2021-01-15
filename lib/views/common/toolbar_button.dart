import 'package:flutter/material.dart';

class SBToolbarButton extends StatelessWidget {
  final void Function() onPress;
  final String text;
  SBToolbarButton(this.text, this.onPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: () {
          this.onPress();
        },
        child: Container(
          child: Text(this.text),
          margin: EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}
