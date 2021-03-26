import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/actions/actions.dart';
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

void main() {
  const btnTextQR = 'Scan QR Code';
  const btnTextInput = 'Change Manually';

  var serverKey = encodeServerKey('192.168.3.144', 3000);

  Store<AppState> store;

  Widget buildTestableWidget(Widget widget) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  group('auth_client', () {
    setUp(() {
      getFactory().store = store = Store<AppState>(
        appReducer,
        initialState: AppState(
          status: Status.noParam(StatusKey.ListTask),
          photoRepo: PhotoRepo(photos: {}, lastTS: 0),
          taskRepo: TaskRepo(tasks: {}, lastTS: 0),
          setting: Setting(
            clientID: 'client-id',
            serverReachable: Reachable.Unknown,
          ),
        ),
      );

      getViewResource().actServer = MockActServer();
      getViewResource().command = MockCommandChannel();
      getViewResource().deviceManager = MockDeviceManager();
    });

    testWidgets('qr scan failed', (WidgetTester tester) async {
      when(getViewResource().deviceManager.isDesktop()).thenReturn(false);

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);

      expect(find.text(btnTextQR), findsOneWidget);
      expect(find.text(btnTextInput), findsOneWidget);

      // press QR Code to call native command and show error dialog
      when(getViewResource().command.takeQRCode()).thenAnswer((_) async {
        throw Exception('invalid qr code');
      });

      await tester.tap(find.text(btnTextQR));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // alert dialog disappear
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('qr scan succeed', (WidgetTester tester) async {
      when(getViewResource().deviceManager.isDesktop()).thenReturn(false);

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);

      expect(find.text(btnTextQR), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);

      // press QR Code to call native command and succeed
      when(getViewResource().command.takeQRCode()).thenAnswer((_) async {
        store.dispatch(SettingServerKeyAction(serverKey: serverKey));
      });

      await tester.tap(find.text(btnTextQR));
      await tester.pumpAndSettle();

      // not reachable
      store.dispatch(SettingServerReachableAction(reachable: false));
      await tester.pumpAndSettle();
      expect(find.text('Unreachable'), findsOneWidget);

      // reachable
      store.dispatch(SettingServerReachableAction(reachable: true));
      await tester.pumpAndSettle();
      expect(find.text('Reachable'), findsOneWidget);
    });

    testWidgets('manual input - keyboard', (WidgetTester tester) async {
      when(getViewResource().deviceManager.isDesktop()).thenReturn(false);

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);

      expect(find.text(btnTextInput), findsOneWidget);
      await tester.tap(find.text(btnTextInput));
      await tester.pump();

      // show manually input
      expect(find.byType(TextField), findsOneWidget);

      // input incorrect
      await tester.enterText(find.byType(TextField), 'add wrong code');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // show error
      expect(find.text('* Invalid Server Key'), findsOneWidget);

      // input correct
      await tester.enterText(find.byType(TextField), serverKey);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // leave manual input
      expect(find.text(btnTextInput), findsOneWidget);

      // going to change server-key
      var capture = verify(
              getViewResource().actServer.actChangeServerKey(any, captureAny))
          .captured;
      expect(capture[0], serverKey);
    });

    testWidgets('manual input - button', (WidgetTester tester) async {
      when(getViewResource().deviceManager.isDesktop()).thenReturn(false);

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);

      expect(find.text(btnTextInput), findsOneWidget);
      await tester.tap(find.text(btnTextInput));
      await tester.pump();

      // show manually input
      expect(find.byType(TextField), findsOneWidget);

      // input incorrect
      await tester.enterText(find.byType(TextField), 'add wrong code');
      await tester.tap(find.text('Save'));
      await tester.pump();

      // show error
      expect(find.text('* Invalid Server Key'), findsOneWidget);

      // input correct
      await tester.enterText(find.byType(TextField), serverKey);
      await tester.tap(find.text('Save'));
      await tester.pump();

      // leave manual input
      expect(find.text(btnTextInput), findsOneWidget);

      // going to change server-key
      var capture = verify(
              getViewResource().actServer.actChangeServerKey(any, captureAny))
          .captured;
      expect(capture[0], serverKey);
    });

    testWidgets('manual input - escape', (WidgetTester tester) async {
      when(getViewResource().deviceManager.isDesktop()).thenReturn(false);

      var widget = buildTestableWidget(AuthPage());
      await tester.pumpWidget(widget);

      expect(find.text(btnTextInput), findsOneWidget);
      await tester.tap(find.text(btnTextInput));
      await tester.pump();

      // show manually input
      expect(find.byType(TextField), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      // leave manual input
      expect(find.text(btnTextInput), findsOneWidget);
    });
  });
}
