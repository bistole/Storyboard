import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:storyboard/views/config/config.dart';

class LogReader {
  String _logTag = (LogReader).toString();

  String _filename;
  File _file;
  int _offset = 0;
  int _total = 0;
  Stream _stream;

  StreamController _streamOutputController;
  Stream<String> _streamOutput;

  LogReader() {
    _streamOutputController = StreamController<String>();
    _streamOutput = _streamOutputController.stream.asBroadcastStream();
  }

  void dispose() {
    _streamOutputController.close();
    _streamOutputController = null;
  }

  void addListener(void Function(String) listener) {
    _streamOutput.listen(listener);
  }

  void readToStream() {
    _stream = utf8.decoder.bind(
      this._file.openRead(this._offset).map<List<int>>((event) {
        this._offset += event.length;
        return event;
      }),
    );
    _stream.transform(LineSplitter()).listen(
      (event) {
        _streamOutputController.sink.add(event);
      },
      onError: (err) {
        getViewResource().logger.error(_logTag, 'read backend log error: $err');
      },
      onDone: () {
        checkUpdates();
      },
    );
  }

  void setFilename(String filename) {
    // do nothing if set same filename
    if (this._filename == filename) return;

    if (_stream != null) {
      _stream = null;
    }

    this._filename = filename;
    this._file = File(filename);
    this._total = this._file.lengthSync();
    this._offset = 0;

    readToStream();
  }

  void checkUpdates() {
    Future.delayed(Duration(seconds: 1), () {
      File(this._filename);
      if (this._file.lengthSync() != this._total) {
        this._total = this._file.lengthSync();
        readToStream();
      } else {
        checkUpdates();
      }
    });
  }
}
