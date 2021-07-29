import 'package:flutter/services.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/redux/models/note_repo.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

import '../../../common.dart';

class MockCommandChannel extends Mock implements CommandChannel {}

Type typeof<T>() => T;

void main() {
  Store<AppState> store;

  final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
  final noteJson = {
    'uuid': uuid,
    'title': 'original Title',
    'deleted': 0,
    'updatedAt': 1606406017,
    'createdAt': 1606406017,
    '_ts': 1606406017000,
  };

  group(
    "HomePage",
    () {
      setUp(() {
        setFactoryLogger(MockLogger());
        getFactory().store = store = getMockStore(
          status: Status.noParam(StatusKey.ListNote),
          nr: NoteRepo(
            notes: <String, Note>{uuid: Note.fromJson(noteJson)},
            lastTS: 0,
          ),
        );

        getViewResource().actNotes = ActNotes();
        getViewResource().actNotes.setLogger(MockLogger());
        getViewResource().actNotes.setNetQueue(MockNetQueue());
        getViewResource().command = MockCommandChannel();
      });

      testWidgets("update item succ", (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // find one note
        var gKey =
            getViewResource().getGlobalKeyByName("NOTE-LIST-TEXT:" + uuid);
        RichText rt = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt.text.toPlainText(), 'original Title');

        // tap the rich text
        await tester.tap(find.byKey(gKey));
        await tester.pumpAndSettle();

        // Find TextField
        expect(find.byType(TextField), findsOneWidget);

        // Input one item and submit
        await tester.enterText(find.byType(TextField), 'Add updated list');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListNote);
        expect(store.state.noteRepo.notes.length, 1);
        expect(store.state.noteRepo.notes[uuid].title, "Add updated list");

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);

        RichText rt2 = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt2.text.toPlainText(), 'Add updated list');
      });

      testWidgets("update item cancel", (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // find one note
        var gKey =
            getViewResource().getGlobalKeyByName("NOTE-LIST-TEXT:" + uuid);
        RichText rt = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt.text.toPlainText(), 'original Title');

        // tap the rich text
        await tester.tap(find.byKey(gKey));
        await tester.pumpAndSettle();

        // Find TextField
        expect(find.byType(TextField), findsOneWidget);

        // Input one item and submit
        await tester.enterText(find.byType(TextField), 'Add updated list');

        // wait
        await tester.idle();
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // press 'escape'
        await simulateKeyDownEvent(LogicalKeyboardKey.escape);
        await simulateKeyUpEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListNote);
        expect(store.state.noteRepo.notes.length, 1);
        expect(store.state.noteRepo.notes[uuid].title, "original Title");

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);

        RichText rt2 = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt2.text.toPlainText(), 'original Title');
      });
    },
  );
}
