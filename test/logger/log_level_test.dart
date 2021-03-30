import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/logger/log_level.dart';

void main() {
  test('init', () {
    LogLevel fl = LogLevel.fatal();
    expect(fl.level, LogLevel.LOG_LEVEL_FATAL);
    expect(fl.name(), 'FATAL');

    LogLevel el = LogLevel.error();
    expect(el.level, LogLevel.LOG_LEVEL_ERROR);
    expect(el.name(), 'ERROR');

    LogLevel wl = LogLevel.warn();
    expect(wl.level, LogLevel.LOG_LEVEL_WARN);
    expect(wl.name(), 'WARN');

    LogLevel il = LogLevel.info();
    expect(il.level, LogLevel.LOG_LEVEL_INFO);
    expect(il.name(), 'INFO');

    LogLevel dl = LogLevel.debug();
    expect(dl.level, LogLevel.LOG_LEVEL_DEBUG);
    expect(dl.name(), 'DEBUG');
  });

  test('upper lower - fatal', () {
    LogLevel l = LogLevel(LogLevel.LOG_LEVEL_FATAL);
    expect(l.canUpper(), false);
    expect(l.canLower(), true);

    LogLevel ul = l.upper();
    expect(ul.level, LogLevel.LOG_LEVEL_FATAL);

    LogLevel ll = l.lower();
    expect(ll.level, LogLevel.LOG_LEVEL_ERROR);
  });

  test('upper lower - debug', () {
    LogLevel l = LogLevel(LogLevel.LOG_LEVEL_DEBUG);
    expect(l.canUpper(), true);
    expect(l.canLower(), false);

    LogLevel ul = l.upper();
    expect(ul.level, LogLevel.LOG_LEVEL_INFO);

    LogLevel ll = l.lower();
    expect(ll.level, LogLevel.LOG_LEVEL_DEBUG);
  });

  test('.valueOfName', () {
    expect(LogLevel.valueOfName("ERROR").level, LogLevel.LOG_LEVEL_ERROR);

    expect(LogLevel.valueOfName("ANYTHING").level, LogLevel.LOG_LEVEL_DEBUG);
  });

  test('.compare', () {
    expect(LogLevel(LogLevel.LOG_LEVEL_DEBUG), LogLevel.debug());

    expect(LogLevel.debug().hashCode, isNotNull);
  });
}
