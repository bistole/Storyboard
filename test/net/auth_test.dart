import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/auth.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

var mockHostname = "192.168.3.146";
var mockPort = 3000;
var mockServerKey = encodeServerKey(mockHostname, mockPort);
var mockURLPrefix = 'http://' + mockHostname + ":" + mockPort.toString();

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NetAuth netAuth;
  Store<AppState> store;
  MockHttpClient httpClient;

  buildStore() {
    getFactory().store = store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        taskRepo: TaskRepo(tasks: {}, lastTS: 0),
        queue: Queue(),
        setting: Setting(
            serverKey: mockServerKey, serverReachable: Reachable.Unknown),
      ),
    );
  }

  group('netPing', () {
    test('netPing succ', () async {
      buildStore();

      httpClient = MockHttpClient();

      netAuth = NetAuth();
      netAuth.setHttpClient(httpClient);

      final responseBody = jsonEncode({
        'pong': true,
      });

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netAuth.netPing(store);

      expect(store.state.setting.serverReachable, Reachable.Yes);
    });

    test('netPing timeout', () async {
      buildStore();

      httpClient = MockHttpClient();

      netAuth = NetAuth();
      netAuth.setHttpClient(httpClient);

      final responseBody = jsonEncode({
        'pong': true,
      });

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 5));
        return http.Response(responseBody, 200);
      });

      await netAuth.netPing(store);

      expect(store.state.setting.serverReachable, Reachable.No);
    });

    test('netPing have exception', () async {
      buildStore();

      httpClient = MockHttpClient();

      netAuth = NetAuth();
      netAuth.setHttpClient(httpClient);

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenThrow(new Exception("unknown error"));

      await netAuth.netPing(store);

      expect(store.state.setting.serverReachable, Reachable.Unknown);
    });
  });
}
