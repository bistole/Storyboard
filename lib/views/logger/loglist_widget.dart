import 'package:flutter/material.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/views/config/config.dart';

class LogListWidget extends StatefulWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  _LogListState createState() => _LogListState();
}

class _LogListState extends State<LogListWidget> {
  List<String> logs;

  @override
  void initState() {
    super.initState();
    logs = List.from(getViewResource().logger.getLogsInCache());

    getViewResource().logger.getStream().listen((line) {
      setState(() {
        logs = [...logs, line];
      });
      Future.delayed(Duration(milliseconds: 500), () {
        widget._scrollController.jumpTo(
          widget._scrollController.position.maxScrollExtent,
        );
      });
    });
  }

  Widget buildWholeLogWithColor(String log, Color color) {
    return SelectableText(
      log,
      style: TextStyle(color: color),
    );
  }

  Widget buildLogWithColorOnLevel(List<String> logSegments, Color color) {
    return SelectableText.rich(
      TextSpan(
        text: logSegments[0] + " " + logSegments[1] + " ",
        children: [
          TextSpan(
            text: logSegments[2],
            style: TextStyle(color: color),
          ),
          TextSpan(text: " " + logSegments.sublist(3).join(" ")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: widget._scrollController,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, i) {
        Color color = Colors.black;
        List<String> logSegments = logs[i].split(" ");

        LogLevel logLevel = LogLevel.debug();
        if (logSegments.length <= 2) {
          logLevel = LogLevel.debug();
        } else {
          logLevel = LogLevel.valueOfName(logSegments[2]);
          if (logLevel == LogLevel.warn()) {
            color = Colors.orange;
          } else if (logLevel == LogLevel.error()) {
            color = Colors.red;
          } else if (logLevel == LogLevel.fatal()) {
            color = Colors.deepPurple;
          }
        }

        return Row(
          children: [
            Expanded(
              child: logLevel == LogLevel.debug()
                  ? buildWholeLogWithColor(logs[i], Colors.grey)
                  : buildLogWithColorOnLevel(logSegments, color),
            ),
          ],
        );
      },
      separatorBuilder: (context, i) => Divider(),
      itemCount: logs.length,
    );
  }
}
