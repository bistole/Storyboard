import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/logger/loglist_widget.dart';

import '../../common.dart';

class MockStream extends Mock implements Stream<String> {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<String> {}

void main() {
  Store<AppState> store;
  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();
  });

  group('LogListWidget', () {
    testWidgets('.getLogsInCache', (WidgetTester tester) async {
      when(getViewResource().logger.getLogsInCache()).thenReturn([
        "2021-02-03 13:00:07 ERROR error",
        "2021-02-03 13:00:08 WARN warning",
        "2021-02-03 13:00:08 FATAL fatal",
        "exception",
      ]);
      Stream<String> mockStream = MockStream();
      when(mockStream.listen(any)).thenAnswer((_) => MockStreamSubscription());
      when(getViewResource().logger.getStream()).thenAnswer((_) => mockStream);

      Widget w = buildTestableWidget(LogListWidget(), store);
      await tester.pumpWidget(w);
    });

    testWidgets('.getStream', (WidgetTester tester) async {
      Stream<String> func() async* {
        yield "2021-02-03 13:00:08 WARN warning";
      }

      when(getViewResource().logger.getLogsInCache()).thenReturn([]);
      when(getViewResource().logger.getStream()).thenAnswer((_) => func());

      Widget w = buildTestableWidget(LogListWidget(), store);
      await tester.pumpWidget(w);

      await tester.pump(Duration(seconds: 1));

      expect(find.byType(SelectableText), findsNWidgets(1));
    });
  });
}
