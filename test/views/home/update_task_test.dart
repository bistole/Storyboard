import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/views/home/page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

class MockNetQueue extends Mock implements NetQueue {}

Type typeof<T>() => T;

void main() {
  Store<AppState> store;

  final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
  final taskJson = {
    'uuid': uuid,
    'title': 'original Title',
    'deleted': 0,
    'updatedAt': 1606406017,
    'createdAt': 1606406017,
    '_ts': 1606406017000,
  };
  Widget buildTestableWidget(Widget widget) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        home: widget,
      ),
    );
  }

  group(
    "update item",
    () {
      setUp(() {
        store = Store<AppState>(
          appReducer,
          initialState: AppState(
            status: Status.noParam(StatusKey.ListTask),
            tasks: <String, Task>{uuid: Task.fromJson(taskJson)},
          ),
        );
        setStore(store);

        setNetQueue(MockNetQueue());
      });

      testWidgets("update item succ", (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'));
        await tester.pumpWidget(widget);

        // find one task
        expect(find.text('original Title'), findsOneWidget);

        // find popmenu button
        var popbtnFinder = find.byType(typeof<PopupMenuButton<String>>());
        expect(popbtnFinder, findsOneWidget);

        // tap the button
        await tester.tap(popbtnFinder);
        await tester.pumpAndSettle();

        // find two buttons
        var itmFinder = find.byType(typeof<PopupMenuItem<String>>());
        expect(itmFinder, findsNWidgets(2));

        // tap change
        var changeItmElem = tester.element(itmFinder.last);
        expect(
          (changeItmElem.widget as PopupMenuItem<String>).value,
          "change",
        );
        await tester.tap(itmFinder.last);
        await tester.pumpAndSettle();

        // Find TextField
        expect(find.byType(TextField), findsOneWidget);

        // Input one item and submit
        await tester.enterText(find.byType(TextField), 'Add updated list');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListTask);
        expect(store.state.tasks.length, 1);
        expect(store.state.tasks[uuid].title, "Add updated list");

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Add updated list'), findsOneWidget);
      });
    },
  );
}
