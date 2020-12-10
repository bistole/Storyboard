// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:storyboard/models/app.dart';
import 'package:storyboard/models/status.dart';
import 'package:storyboard/models/task.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/reducers/app_reducer.dart';
import 'package:storyboard/views/home/page.dart';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {
  @override
  String toString() {
    return "I am the mock";
  }
}

void main() {
  Store<AppState> store;

  Widget buildTestableWidget(Widget widget) {
    store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        tasks: <String, Task>{},
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
    "add item",
    () {
      testWidgets('add item succ', (WidgetTester tester) async {
        // Setup HTTP Response
        final client = MockClient();
        setHTTPClient(client);

        final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
        final responseBody = jsonEncode({
          'succ': true,
          'task': {
            'uuid': uuid,
            'title': 'new Title',
            'deleted': 0,
            'updatedAt': 1606506017,
            'createdAt': 1606506017,
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

        // Verify http request is correct
        var captured = verify(client.post(
          captureAny,
          headers: anyNamed("headers"),
          body: captureAnyNamed("body"),
          encoding: anyNamed("encoding"),
        )).captured;

        expect(captured[0], "http://localhost:3000/tasks");
        expect(captured[1], '{"title":"Add new list"}');

        // Verify the redux state is correct
        expect(store.state.status.status, StatusKey.ListTask);
        expect(store.state.tasks.length, 1);
        expect(store.state.tasks[uuid], isNotNull);

        // verify the UI is correct
        expect(find.byType(TextField), findsNothing);
        expect(find.text('ADD'), findsOneWidget);
        expect(find.text('new Title'), findsOneWidget);
      });
    },
  );
}
