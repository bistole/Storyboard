import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/logger/log_level.dart';

import 'package:storyboard/logger/logger.dart';

void main() {
  test('init', () {
    var logger = Logger();
    logger.setDir(Directory("."));

    // check filename
    var filename = logger.getFilename();
    expect(filename, matches('\.\/log-[0-9]{4}-[0-9]{2}-[0-9]{2}\.log'));

    // delete it finally
    File(filename).delete();
  });

  test('log level', () {
    var logger = Logger();
    logger.setLevel(LogLevel.info());
    expect(logger.getLevel().level, LogLevel.LOG_LEVEL_INFO);
  });

  test('write with levels', () async {
    var logger = Logger();
    logger.setDir(Directory("."));
    logger.setLevel(LogLevel.debug());

    logger.debug("TESTER", "is debug");
    logger.info("TESTER", "is info");
    logger.warn("TESTER", "is warning");
    logger.error("TESTER", "is error");
    logger.fatal("TESTER", "is fatal");
    logger.always("TESTER", "is always");

    logger.stop();
    var filename = logger.getFilename();
    var file = File(filename);

    await Future.delayed(Duration(milliseconds: 100));
    var lines = await file.readAsLines();
    var len = lines.length;
    expect(len, greaterThan(7));

    expect(lines[len - 7], matches('ALWAYS Logger Set Log Level: DEBUG'));
    expect(lines[len - 6], matches('DEBUG TESTER is debug'));
    expect(lines[len - 5], matches('INFO TESTER is info'));
    expect(lines[len - 4], matches('WARN TESTER is warning'));
    expect(lines[len - 3], matches('ERROR TESTER is error'));
    expect(lines[len - 2], matches('FATAL TESTER is fatal'));
    expect(lines[len - 1], matches('ALWAYS TESTER is always'));

    // delete it finally
    File(filename).delete();
  });

  test('get stream', () async {
    var logger = Logger();
    logger.setLevel(LogLevel.warn());

    await Future.delayed(Duration(milliseconds: 100));
    var lineCnt = logger.getLogsInCache().length;
    logger.warn("TESTER", "is warning");

    await Future.delayed(Duration(milliseconds: 100));
    var moreLineCnt = logger.getLogsInCache().length;

    expect(lineCnt + 1, moreLineCnt);

    logger.getStream().listen((event) {
      expect(event, matches('ERROR TESTER is error'));
    });

    logger.error("TESTER", "is error");
  });

  test('set dir again', () async {
    var logger = Logger();
    logger.setDir(Directory("."));

    await Future.delayed(Duration(milliseconds: 100));
    logger.setDir(Directory("."));

    await Future.delayed(Duration(milliseconds: 100));

    // delete it finally
    File(logger.getFilename()).delete();
  });
}
