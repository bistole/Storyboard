import 'package:flutter/material.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';

class LogLevelWidget extends StatefulWidget {
  @override
  _LogLevelWidgetState createState() => _LogLevelWidgetState();
}

class _LogLevelWidgetState extends State<LogLevelWidget> {
  LogLevel logLevel;

  @override
  void initState() {
    super.initState();
    logLevel = getViewResource().logger.getLevel();
  }

  void logLevelUpper() {
    LogLevel l = getViewResource().logger.getLevel();
    l = l.upper();
    getViewResource().logger.setLevel(l);
    setState(() {
      this.logLevel = l;
    });
  }

  void logLevelLower() {
    LogLevel l = getViewResource().logger.getLevel();
    l = l.lower();
    getViewResource().logger.setLevel(l);
    setState(() {
      this.logLevel = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(children: [
        Expanded(
          child: Text(
            "Log Level >= " + logLevel.name(),
            style: Theme.of(context).textTheme.headline3.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        TextButton.icon(
          onPressed: logLevel.canUpper() ? logLevelUpper : null,
          icon: Icon(AppIcons.level_up, color: Colors.white),
          label: Text(""),
        ),
        TextButton.icon(
          onPressed: logLevel.canLower() ? logLevelLower : null,
          icon: Icon(AppIcons.level_down, color: Colors.white),
          label: Text(""),
        )
      ]),
    );
  }
}
