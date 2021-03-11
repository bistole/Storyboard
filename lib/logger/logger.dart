import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:storyboard/logger/log_level.dart';

typedef LoggerCallback = void Function(Error err, String line);

const MAX_LOG_IN_CACHE = 100;

class EndOfStreamError extends Error {}

class Logger {
  String _LOG_TAG = (Logger).toString();

  LogLevel _logLevel;

  StreamController<String> _streamController;
  Stream<String> _stream;
  Queue<String> _logsInCache;
  File _file;
  IOSink _sink;

  Logger() {
    _logLevel = LogLevel.debug();

    _file = null;
    _sink = null;
    _logsInCache = Queue<String>();

    _streamController = StreamController<String>();
    _streamController.stream;
    _stream = _streamController.stream.asBroadcastStream();
    _stream.listen((line) {
      print(line);
      if (this._logsInCache.length > MAX_LOG_IN_CACHE) {
        this._logsInCache.removeFirst();
      }
      this._logsInCache.addLast(line);
    });
  }

  void setLevel(LogLevel logLevel) {
    this.always(_LOG_TAG, "Set Log Level: ${logLevel.name()}");
    _logLevel = logLevel;
  }

  LogLevel getLevel() {
    return _logLevel;
  }

  void setDir(Directory dir) {
    if (this._file != null) {
      if (this._sink != null) {
        this._sink.close();
        this._sink = null;
      }
      this._file = null;
    }

    var ts = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var filename = dir.path + '/log-$ts.log';
    this._file = File(filename);

    this.always(_LOG_TAG, "Log filename: $filename");

    this._sink = this._file.openWrite(mode: FileMode.append);
    for (String line in this._logsInCache) {
      this._sink.write(line);
    }

    this._stream.listen(
      (String line) {
        this._sink.write(line);
      },
      onDone: () {
        this._sink.close();
        this._sink = null;
      },
      onError: (err) {
        this._sink.close();
        this._sink = null;
      },
    );
  }

  Stream<String> getStream() {
    return this._stream;
  }

  void stop() {
    this._streamController.close();
  }

  List<String> getLogsInCache() {
    return this._logsInCache.toList();
  }

  void _log(int level, String tag, String message) {
    if (this._logLevel.level > level) return;

    var ts = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    var levelName = LogLevel.LEVEL_NAMES[level];
    String output = '$ts $levelName $tag $message';

    // push to stream
    this._streamController.add(output);
  }

  void debug(String tag, String message) =>
      this._log(LogLevel.LOG_LEVEL_DEBUG, tag, message);
  void info(String tag, String message) =>
      this._log(LogLevel.LOG_LEVEL_INFO, tag, message);
  void warn(String tag, String message) =>
      this._log(LogLevel.LOG_LEVEL_WARN, tag, message);
  void error(String tag, String message) =>
      this._log(LogLevel.LOG_LEVEL_ERROR, tag, message);
  void fatal(String tag, String message) =>
      this._log(LogLevel.LOG_LEVEL_FATAL, tag, message);
  void always(String tag, String message) =>
      this._log(LogLevel.LOG_LEVEL_ALWAYS, tag, message);
}
