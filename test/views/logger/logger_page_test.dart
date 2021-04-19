import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/logger/page.dart';

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

  testWidgets('init', (WidgetTester tester) async {
    when(getViewResource().logger.getLevel()).thenReturn(LogLevel.debug());
    when(getViewResource().logger.getLogsInCache()).thenReturn([]);

    MockStream mockStream = MockStream();
    when(mockStream.listen(any)).thenAnswer((_) => MockStreamSubscription());
    when(getViewResource().logger.getStream()).thenAnswer((_) => mockStream);

    Widget w = buildTestableWidget(LoggerPage(), store);
    await tester.pumpWidget(w);
    await tester.pump(Duration(seconds: 1));
  });
}
