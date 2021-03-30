import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/logger/page.dart';

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
    when(getViewResource().logger.getLevel()).thenReturn(LogLevel.debug());
    when(getViewResource().logger.getLogsInCache()).thenReturn([]);
    when(getViewResource().logger.getStream()).thenAnswer((_) => MockStream());

    Widget w = buildDefaultTestableWidget(LoggerPage(), store);
    await tester.pumpWidget(w);
    await tester.pump(Duration(seconds: 1));
  });
}
