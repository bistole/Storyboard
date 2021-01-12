import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/tasks.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockActTasks extends Mock implements ActTasks {}

void main() {
  Store<AppState> store;
  MockHttpClient httpClient;
  ActTasks actTasks;
  NetTasks netTasks;

  buildStore(Map<String, Task> tasks) {
    getFactory().store = store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        taskRepo: TaskRepo(tasks: tasks, lastTS: 0),
        queue: Queue(),
      ),
    );
  }

  getJsonTaskObject() {
    return {
      'uuid': 'uuid',
      'title': 'title of task',
      'deleted': 0,
      'updatedAt': 1606506017,
      'createdAt': 1606506017,
      '_ts': 1606506017000,
    };
  }

  Task getTaskObject() {
    return Task(
      uuid: 'uuid',
      title: 'title of task',
      deleted: 0,
      updatedAt: 1606506017,
      createdAt: 1606506017,
      ts: 1606506017000,
    );
  }

  group("netFetchTasks", () {
    setUp(() {
      httpClient = MockHttpClient();
      actTasks = MockActTasks();

      netTasks = NetTasks();
      netTasks.setHttpClient(httpClient);
      netTasks.setActTasks(actTasks);
    });

    test("fetch new task", () async {
      // no photo existed
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'tasks': [getJsonTaskObject()],
      });
      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netFetchTasks(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/tasks?ts=1&c=100');

      expect(store.state.taskRepo.tasks, {'uuid': getTaskObject()});
    });

    test('fetch existed task', () async {
      buildStore({
        'uuid': getTaskObject().copyWith(
          updatedAt: 1600000000,
          createdAt: 1600000000,
          ts: 1600000000000,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'tasks': [getJsonTaskObject()],
      });

      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netFetchTasks(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/tasks?ts=1&c=100');

      expect(store.state.taskRepo.tasks, {
        'uuid': getTaskObject(),
      });
    });

    test('fetch deleting task', () async {
      buildStore({'uuid': getTaskObject()});

      final responseBody = jsonEncode({
        'succ': true,
        'tasks': [
          getJsonTaskObject()..addAll({'deleted': 1})
        ],
      });

      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netFetchTasks(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/tasks?ts=1&c=100');

      expect(store.state.taskRepo.tasks, {});
    });

    test("no retry", () async {
      var savedCountPerFetch = countPerFetch;
      countPerFetch = 2;
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'tasks': [getJsonTaskObject()],
      });
      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netFetchTasks(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/tasks?ts=1&c=2');

      verifyNever(actTasks.actFetchTasks());

      countPerFetch = savedCountPerFetch;
    });

    test("retry", () async {
      var savedCountPerFetch = countPerFetch;
      countPerFetch = 2;
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'tasks': [
          getJsonTaskObject(),
          getJsonTaskObject()..addAll({'uuid': 'uuid2'}),
        ],
      });
      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netFetchTasks(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/tasks?ts=1&c=2');

      verify(actTasks.actFetchTasks()).called(1);

      countPerFetch = savedCountPerFetch;
    });
  });

  group('netCreateTask', () {
    setUp(() {
      httpClient = MockHttpClient();
      actTasks = MockActTasks();

      netTasks = NetTasks();
      netTasks.setHttpClient(httpClient);
      netTasks.setActTasks(actTasks);
    });

    test("create succ", () async {
      // no photo existed
      buildStore({'uuid': getTaskObject().copyWith(ts: 0)});

      final responseBody = jsonEncode({
        'succ': true,
        'task': getJsonTaskObject(),
      });

      when(httpClient.post(
        startsWith(URLPrefix),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netCreateTask(store, uuid: 'uuid');

      var captured = verify(httpClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).captured;

      expect(captured[0], URLPrefix + '/tasks');
      expect(captured[1]['Content-Type'], 'application/json');
      expect(captured[2], jsonEncode(getTaskObject().copyWith(ts: 0).toJson()));

      expect(store.state.taskRepo.tasks['uuid'].ts, 1606506017000);
    });
  });

  group('netUpdateTask', () {
    setUp(() {
      httpClient = MockHttpClient();
      actTasks = MockActTasks();

      netTasks = NetTasks();
      netTasks.setHttpClient(httpClient);
      netTasks.setActTasks(actTasks);
    });

    test('update succ', () async {
      buildStore({'uuid': getTaskObject().copyWith(ts: 1606500000000)});

      final responseBody = jsonEncode({
        'succ': true,
        'task': getJsonTaskObject(),
      });

      when(httpClient.post(
        startsWith(URLPrefix),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netTasks.netUpdateTask(store, uuid: 'uuid');

      var captured = verify(httpClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).captured;

      expect(captured[0], URLPrefix + '/tasks/uuid');
      expect(captured[1]['Content-Type'], 'application/json');
      expect(captured[2],
          jsonEncode(getTaskObject().copyWith(ts: 1606500000000).toJson()));

      expect(store.state.taskRepo.tasks['uuid'].ts, 1606506017000);
    });
  });

  group('netDeleteTask', () {
    setUp(() {
      httpClient = MockHttpClient();
      actTasks = MockActTasks();

      netTasks = NetTasks();
      netTasks.setHttpClient(httpClient);
      netTasks.setActTasks(actTasks);
    });

    test('delete succ', () async {
      buildStore({'uuid': getTaskObject()});

      final responseBody = jsonEncode({
        'succ': true,
        'task': getJsonTaskObject()..addAll({'deleted': 1}),
      });
      when(httpClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value(utf8.encode(responseBody)), 200);
      });

      await netTasks.netDeleteTask(store, uuid: 'uuid');

      var capHttp =
          verify(httpClient.send(captureAny)).captured.first as http.Request;
      expect(capHttp.method, 'DELETE');
      expect(capHttp.url.toString(), URLPrefix + '/tasks/uuid');
      expect(capHttp.body, jsonEncode({"updatedAt": 1606506017}));

      expect(store.state.taskRepo.tasks['uuid'], isNull);
    });
  });
}
