// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/services.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';

import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../common.dart';

class MockCommandChannel extends Mock implements CommandChannel {}

void main() {
  Store<AppState> store;

  group(
    "add item",
    () {
      setUp(() {
        setFactoryLogger(MockLogger());
        getFactory().store = store = getMockStore(
          status: Status.noParam(StatusKey.ListTask),
        );

        getViewResource().actTasks = ActTasks();
        getViewResource().actTasks.setLogger(MockLogger());
        getViewResource().actTasks.setNetQueue(MockNetQueue());
        getViewResource().command = MockCommandChannel();
      });

      testWidgets('add item succ', (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // Add Button here
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('ADD TASK'), findsOneWidget);

        // Tap 'ADD' button
        await tester.tap(find.text('ADD TASK'));
        await tester.pump();

        // Find TextField
        expect(find.byType(TextField), findsOneWidget);

        // Input one item and submit
        await tester.enterText(find.byType(TextField), 'Add new list');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(store.state.taskRepo.tasks.length, 1);
        int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1;
        int tsBefore = ts - 6;
        Task task = store.state.taskRepo.tasks.values.first;

        expect(store.state.taskRepo.tasks[task.uuid], isNotNull);
        expect(task.title, 'Add new list');
        expect(task.deleted, 0);
        expect(task.updatedAt, lessThan(ts));
        expect(task.updatedAt, greaterThan(tsBefore));
        expect(task.createdAt, task.updatedAt);
        expect(task.ts, 0);

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListTask);

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('ADD TASK'), findsOneWidget);

        var gKey =
            getViewResource().getGlobalKeyByName("TASK-LIST-TEXT:" + task.uuid);
        expect(find.byKey(gKey), findsOneWidget);
        RichText rt2 = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt2.text.toPlainText(), 'Add new list');
      });

      testWidgets('add item cancel', (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // Add Button here
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('ADD TASK'), findsOneWidget);

        // Tap 'ADD' button
        await tester.tap(find.text('ADD TASK'));
        await tester.pump();

        // Find TextField
        expect(find.byType(TextField), findsOneWidget);

        // Input one item and submit
        await tester.enterText(find.byType(TextField), 'Add new list');

        // wait
        await tester.idle();
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // press 'escape'
        await simulateKeyDownEvent(LogicalKeyboardKey.escape);
        await simulateKeyUpEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(store.state.taskRepo.tasks.length, 0);
        expect(store.state.status.status, StatusKey.ListTask);

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('ADD TASK'), findsOneWidget);
      });
    },
  );
}
