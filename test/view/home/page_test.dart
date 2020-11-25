// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import '../../../lib/view/home/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(home: widget);
  }

  testWidgets('add item', (WidgetTester tester) async {
    // home page
    var widget = buildTestableWidget(HomePage(title: 'title'));
    await tester.pumpWidget(widget);

    // Add Button here
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('ADD'), findsOneWidget);

    // Tap 'ADD' button
    await tester.tap(find.text('ADD'));
    await tester.pump();

    // Find TextField
    expect(find.byType(TextField), findsOneWidget);

    // Input one item and submit
    await tester.enterText(find.byType(TextField), 'Add new list');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // check new line found
    expect(find.byType(TextField), findsNothing);
    expect(find.text('ADD'), findsOneWidget);
    expect(find.text('Add new list'), findsOneWidget);
  });

  testWidgets('Cancel adding item', (WidgetTester tester) async {
    // home page
    var widget = buildTestableWidget(HomePage(title: 'title'));
    await tester.pumpWidget(widget);

    // Add Button here
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('ADD'), findsOneWidget);

    // Tap 'ADD' button
    await tester.tap(find.text('ADD'));
    await tester.pump();

    // Find TextField
    expect(find.byType(TextField), findsOneWidget);

    // Cancel
    await tester.enterText(
        find.byType(TextField), 'new list will be cancelled');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    // check no new line found
    expect(find.byType(TextField), findsNothing);
    expect(find.text('ADD'), findsOneWidget);
    expect(find.text('new list will be cancelled'), findsNothing);
  });
}
