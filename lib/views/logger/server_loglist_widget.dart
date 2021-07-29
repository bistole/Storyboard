import 'package:flutter/material.dart';
import 'package:storyboard/logger/log_reader.dart';
import 'package:storyboard/logger/log_reader_factory.dart';

class ServerLogListWidget extends StatefulWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  _ServerLogListState createState() => _ServerLogListState();
}

class _ServerLogListState extends State<ServerLogListWidget> {
  LogReader reader;
  List<String> lines;

  void updateLog(line) {
    setState(() {
      lines.add(line);
    });
  }

  @override
  void initState() {
    // init reader
    lines = [];

    reader = getLogReaderFactory().createLogReader();
    reader.setFilename(getLogReaderFactory().getTodayFilename());
    reader.addListener(updateLog);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: widget._scrollController,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, i) {
        return Row(
          children: [
            Expanded(child: Text(lines[i])),
          ],
        );
      },
      separatorBuilder: (context, i) => Divider(),
      itemCount: lines.length,
    );
  }
}
