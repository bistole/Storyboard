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
import 'package:storyboard/views/home/note/note_widget.dart';

import '../../../common.dart';

class MockCommandChannel extends Mock implements CommandChannel {}

Type typeof<T>() => T;

void main() {
  Store<AppState> store;

  final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
  final noteJson = {
    'uuid': uuid,
    'title': 'will delete title',
    'deleted': 0,
    'updatedAt': 1606406017,
    'createdAt': 1606406017,
    '_ts': 1606406017000,
  };

  group(
    "delete item",
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

      testWidgets("delete item succ", (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // find one note
        var gKey =
            getViewResource().getGlobalKeyByName("NOTE-LIST-TEXT:" + uuid);
        RichText rt = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt.text.toPlainText(), 'will delete title');

        // find delete icon
        expect(find.byIcon(Icons.delete), findsOneWidget);

        // hover
        final gesture = await tester.createGesture();
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await tester.pump();

        await gesture.moveTo(tester.getCenter(find.byType(NoteWidget)));
        await tester.pumpAndSettle();

        // tap to delete
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListNote);
        expect(store.state.noteRepo.notes.length, 1);
        expect(store.state.noteRepo.notes[uuid].deleted, 1);

        // verify the UI is correct
        expect(find.byKey(gKey), findsNothing);
      });
    },
  );
}
