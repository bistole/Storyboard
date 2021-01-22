import 'package:flutter/material.dart';

class SBButton extends StatelessWidget {
  final void Function() onPress;
  final String text;
  final Icon icon;
  SBButton(this.onPress, {this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Container(
        child: ElevatedButton.icon(
          onPressed: this.onPress,
          label: Text(
            this.text == null ? "" : this.text,
            style: TextStyle(color: Colors.white),
          ),
          icon: icon,
          style: ButtonStyle(
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 4)),
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.primary),
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 4),
      );
    }
    return Container(
      child: ElevatedButton(
        onPressed: this.onPress,
        child: Text(
          this.text,
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
          padding:
              MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 4)),
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
