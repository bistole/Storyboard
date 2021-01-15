import 'package:flutter/material.dart';

class SBToolbarButton extends StatelessWidget {
  final void Function() onPress;
  final String text;
  final Icon icon;
  SBToolbarButton(this.onPress, {this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Container(
        child: TextButton.icon(
          onPressed: this.onPress,
          label: Text(this.text == null ? "" : this.text),
          icon: icon,
        ),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      );
    }
    return Container(
      child: TextButton(
        onPressed: this.onPress,
        child: Container(
          child: Text(this.text),
          margin: EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}
