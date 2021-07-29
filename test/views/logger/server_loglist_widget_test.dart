import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/log_reader.dart';
import 'package:storyboard/logger/log_reader_factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/logger/server_loglist_widget.dart';

import '../../common.dart';

class LogReaderFactoryMock extends Mock implements LogReaderFactory {}

class LogReaderMock extends Mock implements LogReader {}

void main() {
  Store<AppState> store;
  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();
  });

  group('ServerLogListWidget', () {
    testWidgets('.getFromFile', (WidgetTester tester) async {
      LogReaderFactory fact = LogReaderFactoryMock();
      LogReader reader = LogReaderMock();
      when(fact.createLogReader()).thenReturn(reader);
      when(fact.getTodayFilename()).thenReturn("mock-today-filename");

      setLogReaderFactory(fact);

      Widget w = buildTestableWidget(ServerLogListWidget(), store);
      await tester.pumpWidget(w);
      await tester.pumpAndSettle();

      var capture = verify(reader.addListener(captureAny)).captured;
      expect(capture.length, 1);

      // wait
      (capture[0] as Function(String))("add one line");
      (capture[0] as Function(String))("add two line");
      await tester.pumpAndSettle();

      expect(find.text("add one line"), findsOneWidget);
      expect(find.text("add two line"), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
