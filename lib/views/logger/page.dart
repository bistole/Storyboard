import 'package:flutter/material.dart';
import 'package:storyboard/views/logger/loglevel_widget.dart';
import 'package:storyboard/views/logger/loglist_widget.dart';

class LoggerPage extends StatelessWidget {
  static const routeName = '/logger';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Logger'),
      ),
      body: Column(
        children: [
          LogLevelWidget(),
          Expanded(
            child: LogListWidget(),
          ),
        ],
      ),
    );
  }
}
