import 'package:flutter/material.dart';
import 'package:storyboard/views/common/button.dart';
import 'package:storyboard/views/logger/page.dart';

class LogEntrance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SBButton(
            () {
              Navigator.of(context).pushNamed(
                LoggerPage.routeName,
              );
            },
            text: ' Show Logs ',
          ),
        )
      ],
    );
  }
}
