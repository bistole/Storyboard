import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';

enum LogType {
  user,
  server,
}

typedef ChangeLogTypeCallback = void Function(LogType);

class LogLevelWidget extends StatefulWidget {
  final LogType type;
  final ChangeLogTypeCallback onChangeType;

  LogLevelWidget(this.type, this.onChangeType);

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

  List<Widget> buildWidgetsForUser(BuildContext context) {
    return [
      Container(
        padding: EdgeInsets.all(6),
        child: Text(
          "Log Level >= " + logLevel.name(),
          style: Styles.normalBodyText.copyWith(
            color: Styles.buttonTextColor,
          ),
        ),
      ),
      InkWell(
        child: Container(
          padding: EdgeInsets.all(6),
          child: Icon(
            AppIcons.level_up,
            color: Styles.buttonTextColor,
            size: 16,
          ),
        ),
        onTap: logLevel.canUpper() ? logLevelUpper : null,
      ),
      InkWell(
        child: Container(
          padding: EdgeInsets.all(6),
          child: Icon(
            AppIcons.level_down,
            color: Styles.buttonTextColor,
            size: 16,
          ),
        ),
        onTap: logLevel.canLower() ? logLevelLower : null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(children: [
        CupertinoSegmentedControl(
          children: {
            LogType.user: Container(
              child: Text("User"),
              padding: EdgeInsets.all(8),
            ),
            LogType.server: Container(
              child: Text("Server"),
              padding: EdgeInsets.all(8),
            ),
          },
          groupValue: widget.type,
          selectedColor: Colors.blue,
          onValueChanged: (val) {
            setState(() {
              widget.onChangeType(val);
            });
          },
        ),
        Expanded(child: Container()),
        ...(widget.type == LogType.user ? buildWidgetsForUser(context) : []),
      ]),
    );
  }
}
