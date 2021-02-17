import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/config/config.dart';

class MockDeviceManager extends Mock implements DeviceManager {}

class MockActServer extends Mock implements ActServer {}

class MockCommandChannel extends Mock implements CommandChannel {}

class MockBackendChannel extends Mock implements BackendChannel {}

void main() {
  var newServerKey = encodeServerKey('192.168.77.88', 3000);
  Store<AppState> store;

  Widget buildTestableWidget(Widget widget) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  group('auth_server', () {
    setUp(() {
      getViewResource().actServer = MockActServer();
      getViewResource().backend = MockBackendChannel();
      getViewResource().command = MockCommandChannel();
      getViewResource().deviceManager = MockDeviceManager();
    });

    buildStore(String serverkey) {
      store = Store<AppState>(
        appReducer,
        initialState: AppState(
          status: Status.noParam(StatusKey.ListTask),
          photoRepo: PhotoRepo(photos: {}, lastTS: 0),
          taskRepo: TaskRepo(tasks: {}, lastTS: 0),
          setting: Setting(
            clientID: 'client-id',
            serverKey: serverkey,
            serverReachable: Reachable.Unknown,
          ),
        ),
      );
    }

    testWidgets('open first time', (WidgetTester tester) async {
      buildStore('');
      when(getViewResource().deviceManager.isDesktop()).thenReturn(true);

      when(getViewResource().backend.getCurrentIp())
          .thenAnswer((_) async => "192.168.7.128");
      when(getViewResource().backend.setCurrentIp(any))
          .thenAnswer((_) async => null);
      when(getViewResource().backend.getAvailableIps()).thenAnswer(
          (_) async => {"eth0": "192.168.7.128", "eth1": "192.168.3.110"});

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // not available
      expect(find.text("N/A"), findsOneWidget);

      // two candidates
      expect(find.text('eth0'.toUpperCase()), findsOneWidget);
      expect(find.text('eth1'.toUpperCase()), findsOneWidget);

      // pick current one
      await tester.tap(find.text('eth0'.toUpperCase()));
      await tester.pumpAndSettle();

      // not trigger to change
      verifyNever(getViewResource().backend.setCurrentIp(any));

      // pick another one
      await tester.tap(find.text('eth1'.toUpperCase()));
      await tester.pumpAndSettle();

      // triggered
      var capture =
          verify(getViewResource().backend.setCurrentIp(captureAny)).captured;
      expect(capture[0], '192.168.3.110');
    });

    testWidgets('open with current ip', (WidgetTester tester) async {
      buildStore(newServerKey);
      when(getViewResource().deviceManager.isDesktop()).thenReturn(true);

      when(getViewResource().backend.getCurrentIp())
          .thenAnswer((_) async => "192.168.7.128");
      when(getViewResource().backend.getAvailableIps()).thenAnswer(
          (_) async => {"eth0": "192.168.7.128", "eth1": "192.168.3.110"});

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);
    });
  });
}
