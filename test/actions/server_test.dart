import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';

import '../common.dart';

class MockNetSSE extends Mock implements NetSSE {}

void main() {
  buildStore(String serverKey) {
    return getMockStore(
      status: Status.noParam(StatusKey.ListNote),
      setting: Setting(serverKey: serverKey),
    );
  }

  group('actChangeServerKey', () {
    test('actChangeServerKey', () async {
      int connectCalledTimes = 0;

      NetSSE netSSE = MockNetSSE();
      netSSE.setLogger(MockLogger());
      when(netSSE.reconnect(any)).thenAnswer((_) async {
        connectCalledTimes++;
      });

      String oldServerKey = encodeServerKey('192.168.3.77', 3000);
      Store<AppState> store = buildStore(oldServerKey);

      ActServer actServer = ActServer();
      actServer.setLogger(MockLogger());
      actServer.setNetSSE(netSSE);

      String newServerKey = encodeServerKey('192.168.4.32', 3000);
      actServer.actChangeServerKey(store, newServerKey);

      // wait until called
      while (connectCalledTimes == 0) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      expect(store.state.setting.serverKey, newServerKey);
      expect(connectCalledTimes, 1);
    }, timeout: Timeout(Duration(seconds: 1)));
  });
}
