import 'package:flutter/material.dart';
import 'package:storyboard/views/logger/loglevel_widget.dart';
import 'package:storyboard/views/logger/user_loglist_widget.dart';
import 'package:storyboard/views/logger/server_loglist_widget.dart';

class LoggerPage extends StatefulWidget {
  static const routeName = '/logger';

  @override
  _LoggerPageState createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  LogType type;

  @override
  void initState() {
    type = LogType.user;
    super.initState();
  }

  void onChangeLogType(LogType _type) {
    setState(() {
      type = _type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Logger'),
      ),
      body: Column(
        children: [
          LogLevelWidget(type, onChangeLogType),
          Expanded(
            child: type == LogType.user
                ? UserLogListWidget()
                : ServerLogListWidget(),
          ),
        ],
      ),
    );
  }
}
