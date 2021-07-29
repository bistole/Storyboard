import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/logger/log_reader.dart';
import 'package:storyboard/logger/log_reader_factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/logger/page.dart';

import '../../common.dart';

class LogReaderFactoryMock extends Mock implements LogReaderFactory {}

class LogReaderMock extends Mock implements LogReader {}

class MockStream extends Mock implements Stream<String> {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<String> {}

void main() {
  Store<AppState> store;
  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();

    LogReaderFactory fact = LogReaderFactoryMock();
    LogReader reader = LogReaderMock();
    when(fact.createLogReader()).thenReturn(reader);
    when(fact.getTodayFilename()).thenReturn("mock-today-filename");

    setLogReaderFactory(fact);
  });

  testWidgets('init', (WidgetTester tester) async {
    when(getViewResource().logger.getLevel()).thenReturn(LogLevel.debug());
    when(getViewResource().logger.getLogsInCache()).thenReturn([]);

    MockStream mockStream = MockStream();
    when(mockStream.listen(any)).thenAnswer((_) => MockStreamSubscription());
    when(getViewResource().logger.getStream()).thenAnswer((_) => mockStream);

    Widget w = buildTestableWidget(LoggerPage(), store);
    await tester.pumpWidget(w);
    await tester.pumpAndSettle();

    // tap server
    expect(find.text("Server"), findsOneWidget);
    await tester.tap(find.text("Server"));
    await tester.pumpAndSettle();
  });
}
