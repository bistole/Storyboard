import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/button.dart';

import '../../common.dart';

void main() {
  Store<AppState> store;

  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();
  });

  testWidgets('button with icon', (WidgetTester tester) async {
    var pressed = false;
    var onPress = () {
      pressed = true;
    };
    Widget w = buildTestableWidget(
        SBButton(
          onPress,
          icon: Icon(AppIcons.android),
          text: 'HELLO TEXT',
        ),
        store);
    await tester.pumpWidget(w);

    // find
    expect(find.byIcon(AppIcons.android), findsOneWidget);
    expect(find.text('HELLO TEXT'), findsOneWidget);

    // tap
    var btn = find.ancestor(
      of: find.byIcon(AppIcons.android),
      matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );
    await tester.tap(btn);
    await tester.pumpAndSettle();

    // done
    expect(pressed, true);
  });

  testWidgets('button without icon', (WidgetTester tester) async {
    var pressed = false;
    var onPress = () {
      pressed = true;
    };
    Widget w = buildTestableWidget(
        SBButton(
          onPress,
          text: 'HELLO TEXT',
        ),
        store);
    await tester.pumpWidget(w);

    // find
    expect(find.text('HELLO TEXT'), findsOneWidget);

    // tap
    var btn = find.ancestor(
      of: find.text('HELLO TEXT'),
      matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );
    await tester.tap(btn);
    await tester.pumpAndSettle();

    // done
    expect(pressed, true);
  });
}
