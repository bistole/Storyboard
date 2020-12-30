import 'dart:convert';

import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/views/home/page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

class MockClient extends Mock implements http.Client {
  @override
  String toString() {
    return "I am the mock";
  }
}

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
    store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        tasks: <String, Task>{uuid: Task.fromJson(taskJson)},
      ),
    );
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
      testWidgets("update item succ", (WidgetTester tester) async {
        // Setup HTTP Response
        final client = MockClient();
        setHTTPClient(client);

        final responseBody = jsonEncode({
          'succ': true,
          'task': {
            'uuid': uuid,
            'title': 'updated Title',
            'deleted': 0,
            'updatedAt': 1606506017,
            'createdAt': 1606406017,
            '_ts': 1606506017000,
          },
        });
        when(client.post(
          startsWith(URLPrefix),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
          encoding: anyNamed('encoding'),
        )).thenAnswer((_) async {
          return http.Response(responseBody, 200);
        });

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

        // Verify http request is correct
        var captured = verify(client.post(
          captureAny,
          headers: anyNamed("headers"),
          body: captureAnyNamed("body"),
          encoding: anyNamed("encoding"),
        )).captured;

        expect(captured[0], "http://localhost:3000/tasks/" + uuid);

        var bodyJson = jsonDecode(captured[1]);
        expect(bodyJson['uuid'], uuid);
        expect(bodyJson['title'], "Add updated list");
        var ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        expect(bodyJson['updatedAt'], greaterThan(ts - 5));
        expect(bodyJson['updatedAt'], lessThan(ts + 5));

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListTask);
        expect(store.state.tasks.length, 1);
        expect(store.state.tasks[uuid].title, "updated Title");

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('updated Title'), findsOneWidget);
      });
    },
  );
}
