import 'package:intl/intl.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/log_reader.dart';

class LogReaderFactory {
  LogReader createLogReader() {
    return LogReader();
  }

  String getTodayFilename() {
    var logDir = getFactory().storage.dataHome;
    var ts = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var logFilename = '$logDir/logs/backend-$ts.log';
    return logFilename;
  }
}

LogReaderFactory _factory;

setLogReaderFactory(LogReaderFactory fac) {
  _factory = fac;
}

LogReaderFactory getLogReaderFactory() {
  if (_factory == null) {
    _factory = LogReaderFactory();
  }
  return _factory;
}
