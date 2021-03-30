import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/logger/loglist_widget.dart';

import '../../common.dart';

class MockLogger extends Mock implements Logger {}

class MockStream extends Mock implements Stream<String> {}

void main() {
  Store<AppState> store;
  setUp(() {
    getFactory().store = store = getMockStore();
  });

  testWidgets('init', (WidgetTester tester) async {
    getViewResource().logger = MockLogger();
    when(getViewResource().logger.getLogsInCache()).thenReturn([
      "2021-02-03 13:00:07 ERROR error",
      "2021-02-03 13:00:08 WARN warning",
      "2021-02-03 13:00:08 FATAL fatal",
      "exception",
    ]);
    when(getViewResource().logger.getStream()).thenAnswer((_) => MockStream());

    Widget w = buildDefaultTestableWidget(LogListWidget(), store);
    await tester.pumpWidget(w);
  });

  testWidgets('stream', (WidgetTester tester) async {
    Stream<String> func() async* {
      yield "2021-02-03 13:00:08 WARN warning";
    }

    getViewResource().logger = MockLogger();
    when(getViewResource().logger.getLogsInCache()).thenReturn([]);
    when(getViewResource().logger.getStream()).thenAnswer((_) => func());

    Widget w = buildDefaultTestableWidget(LogListWidget(), store);
    await tester.pumpWidget(w);

    await tester.pump(Duration(seconds: 1));

    expect(find.byType(SelectableText), findsNWidgets(1));
  });
}
