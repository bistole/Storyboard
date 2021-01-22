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
          style: ButtonStyle(
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)),
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      );
    }
    return Container(
      child: TextButton(
        onPressed: this.onPress,
        child: Text(this.text),
        style: ButtonStyle(
          padding:
              MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}
