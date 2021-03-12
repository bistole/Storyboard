import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

void main() {
  group('handleNetworkError', () {
    Store<AppState> store;
    setUp(() {
      var mockServerKey = encodeServerKey('192.168.8.175', 3000);
      store = Store<AppState>(
        appReducer,
        initialState: AppState(
          status: Status.noParam(StatusKey.ListTask),
          photoRepo: PhotoRepo(photos: {}, lastTS: 0),
          taskRepo: TaskRepo(tasks: {}, lastTS: 0),
          queue: Queue(),
          setting:
              Setting(serverKey: mockServerKey, serverReachable: Reachable.Yes),
        ),
      );
    });

    test('handleNetworkError - server denied', () {
      var e = SocketException('Connection refused', osError: OSError("", 60));
      var ret = handleNetworkError(store, e);
      expect(ret, true);
      expect(store.state.setting.serverReachable, Reachable.No);
    });

    test('handleNetworkError - internet is down', () {
      var e = SocketException('Network is down', osError: OSError("", 50));
      var ret = handleNetworkError(store, e);
      expect(ret, true);
      expect(store.state.setting.serverReachable, Reachable.Yes);
    });
  });
}
