// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/services.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';
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
          status: Status.noParam(StatusKey.ListNote),
        );

        getViewResource().actNotes = ActNotes();
        getViewResource().actNotes.setLogger(MockLogger());
        getViewResource().actNotes.setNetQueue(MockNetQueue());
        getViewResource().command = MockCommandChannel();
      });

      testWidgets('add item succ', (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // Add Button here
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('ADD NOTE'), findsOneWidget);

        // Tap 'ADD' button
        await tester.tap(find.text('ADD NOTE'));
        await tester.pump();

        // Find TextField
        expect(find.byType(TextField), findsOneWidget);

        // Input one item and submit
        await tester.enterText(find.byType(TextField), 'Add new list');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(store.state.noteRepo.notes.length, 1);
        int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1;
        int tsBefore = ts - 6;
        Note note = store.state.noteRepo.notes.values.first;

        expect(store.state.noteRepo.notes[note.uuid], isNotNull);
        expect(note.title, 'Add new list');
        expect(note.deleted, 0);
        expect(note.updatedAt, lessThan(ts));
        expect(note.updatedAt, greaterThan(tsBefore));
        expect(note.createdAt, note.updatedAt);
        expect(note.ts, 0);

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListNote);

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('ADD NOTE'), findsOneWidget);

        var gKey =
            getViewResource().getGlobalKeyByName("NOTE-LIST-TEXT:" + note.uuid);
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
        expect(find.text('ADD NOTE'), findsOneWidget);

        // Tap 'ADD' button
        await tester.tap(find.text('ADD NOTE'));
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

        expect(store.state.noteRepo.notes.length, 0);
        expect(store.state.status.status, StatusKey.ListNote);

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('ADD NOTE'), findsOneWidget);
      });
    },
  );
}
