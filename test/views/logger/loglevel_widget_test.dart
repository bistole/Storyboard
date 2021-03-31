import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/logger/loglevel_widget.dart';

import '../../common.dart';

void main() {
  Store<AppState> store;
  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();
  });

  testWidgets('init', (WidgetTester tester) async {
    when(getViewResource().logger.getLevel()).thenReturn(LogLevel.error());

    Widget w = buildDefaultTestableWidget(LogLevelWidget(), store);
    await tester.pumpWidget(w);

    // show log level
    expect(find.text('Log Level >= ERROR'), findsOneWidget);

    expect(find.byIcon(AppIcons.level_up), findsOneWidget);
    expect(find.byIcon(AppIcons.level_down), findsOneWidget);

    // click up
    await tester.tap(find.ancestor(
      of: find.byIcon(AppIcons.level_up),
      matching: find.byWidgetPredicate((widget) => widget is TextButton),
    ));
    await tester.pumpAndSettle();
    var cap1 = verify(getViewResource().logger.setLevel(captureAny)).captured;
    expect((cap1[cap1.length - 1] as LogLevel).level, LogLevel.LOG_LEVEL_FATAL);

    // click down
    await tester.tap(find.ancestor(
      of: find.byIcon(AppIcons.level_down),
      matching: find.byWidgetPredicate((widget) => widget is TextButton),
    ));
    await tester.pumpAndSettle();
    var cap2 = verify(getViewResource().logger.setLevel(captureAny)).captured;
    expect((cap2[cap2.length - 1] as LogLevel).level, LogLevel.LOG_LEVEL_WARN);
  });
}
