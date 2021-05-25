import 'package:flutter/material.dart';
import 'package:storyboard/views/config/styles.dart';

class NotAvailableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Text(
                  "Hello, Storyboard",
                  textDirection: TextDirection.ltr,
                  style: Styles.welcomeTextStyle,
                ),
                margin: EdgeInsets.symmetric(vertical: 16.0),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}
