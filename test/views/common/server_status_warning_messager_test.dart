import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/server_status_warning_messager.dart';
import 'package:storyboard/views/config/config.dart';

import '../../common.dart';

class MockBackendChannel extends Mock implements BackendChannel {}

void main() {
  Store<AppState> store;

  setUp(() {
    setFactoryLogger(MockLogger());
    getViewResource().backend = MockBackendChannel();
    when(getViewResource().backend.getCurrentIp())
        .thenAnswer((_) async => "192.168.7.128");
    when(getViewResource().backend.setCurrentIp(any))
        .thenAnswer((_) async => null);
    when(getViewResource().backend.getAvailableIps()).thenAnswer(
        (_) async => {"eth0": "192.168.7.128", "eth1": "192.168.3.110"});
  });

  group('server is not setup', () {
    setUp(() {
      getFactory().store = store = getMockStore(
        setting: Setting(
          clientID: "",
          serverKey: "",
          serverReachable: Reachable.Unknown,
        ),
      );
    });

    testWidgets('tap on warning', (WidgetTester tester) async {
      NavigatorObserver mockObserver = MockNavigatorObserver();
      Widget w = buildTestableWidgetInMaterial(
        ServerStatusWarningMessage(),
        store,
        navigator: mockObserver,
      );
      await tester.pumpWidget(w);

      expect(find.byIcon(AppIcons.right_open), findsOneWidget);

      RichText rt = find.byType(RichText).evaluate().first.widget as RichText;
      expect(
        rt.text.toPlainText(),
        "Setup desktop app to sync photos and notes.",
      );

      // tap on text
      await tester.tap(find.byType(RichText).first);
      await tester.pumpAndSettle();

      var capture = verify(mockObserver.didPush(captureAny, any)).captured;
      expect((capture[0] as MaterialPageRoute).settings.name, '/');
      expect(
          (capture[1] as MaterialPageRoute).settings.name, AuthPage.routeName);

      expect(find.byType(AuthPage), findsOneWidget);
    });

    testWidgets('tap on next', (WidgetTester tester) async {
      NavigatorObserver mockObserver = MockNavigatorObserver();
      Widget w = buildTestableWidgetInMaterial(
        ServerStatusWarningMessage(),
        store,
        navigator: mockObserver,
      );
      await tester.pumpWidget(w);

      expect(find.byIcon(AppIcons.right_open), findsOneWidget);

      // tap on icon
      await tester.tap(find.byIcon(AppIcons.right_open));
      await tester.pumpAndSettle();

      var capture = verify(mockObserver.didPush(captureAny, any)).captured;
      expect((capture[0] as MaterialPageRoute).settings.name, '/');
      expect(
          (capture[1] as MaterialPageRoute).settings.name, AuthPage.routeName);

      expect(find.byType(AuthPage), findsOneWidget);
    });
  });

  group('server status is unknown', () {
    setUp(() {
      getFactory().store = store = getMockStore(
        setting: Setting(
          clientID: "",
          serverKey: "have a key",
          serverReachable: Reachable.Unknown,
        ),
      );
    });

    testWidgets('no icon, only text', (WidgetTester tester) async {
      NavigatorObserver mockObserver = MockNavigatorObserver();
      Widget w = buildTestableWidgetInMaterial(
        ServerStatusWarningMessage(),
        store,
        navigator: mockObserver,
      );
      await tester.pumpWidget(w);

      expect(find.byType(Icon), findsNothing);

      RichText rt = find.byType(RichText).evaluate().first.widget as RichText;
      expect(
        rt.text.toPlainText(),
        "Try to connect to desktop app...",
      );
    });
  });

  group('server is unreachable', () {
    setUp(() {
      getFactory().store = store = getMockStore(
        setting: Setting(
          clientID: "",
          serverKey: "have a key",
          serverReachable: Reachable.No,
        ),
      );
    });

    testWidgets('tap on warning', (WidgetTester tester) async {
      NavigatorObserver mockObserver = MockNavigatorObserver();
      Widget w = buildTestableWidgetInMaterial(
        ServerStatusWarningMessage(),
        store,
        navigator: mockObserver,
      );
      await tester.pumpWidget(w);

      expect(find.byIcon(AppIcons.right_open), findsOneWidget);

      RichText rt = find.byType(RichText).evaluate().first.widget as RichText;
      expect(
        rt.text.toPlainText(),
        "Failed to connect to desktop app. Check Wi-Fi connection and setup server key again.",
      );

      // tap on text
      await tester.tap(find.byType(RichText).first);
      await tester.pumpAndSettle();

      var capture = verify(mockObserver.didPush(captureAny, any)).captured;
      expect((capture[0] as MaterialPageRoute).settings.name, '/');
      expect(
          (capture[1] as MaterialPageRoute).settings.name, AuthPage.routeName);

      expect(find.byType(AuthPage), findsOneWidget);
    });

    testWidgets('tap on next', (WidgetTester tester) async {
      NavigatorObserver mockObserver = MockNavigatorObserver();
      Widget w = buildTestableWidgetInMaterial(
        ServerStatusWarningMessage(),
        store,
        navigator: mockObserver,
      );
      await tester.pumpWidget(w);

      expect(find.byIcon(AppIcons.right_open), findsOneWidget);

      // tap on icon
      await tester.tap(find.byIcon(AppIcons.right_open));
      await tester.pumpAndSettle();

      var capture = verify(mockObserver.didPush(captureAny, any)).captured;
      expect((capture[0] as MaterialPageRoute).settings.name, '/');
      expect(
          (capture[1] as MaterialPageRoute).settings.name, AuthPage.routeName);

      expect(find.byType(AuthPage), findsOneWidget);
    });
  });

  group('server works', () {
    setUp(() {
      getFactory().store = store = getMockStore(
        setting: Setting(
          clientID: "",
          serverKey: "have a key",
          serverReachable: Reachable.Yes,
        ),
      );
    });

    testWidgets('only container', (WidgetTester tester) async {
      NavigatorObserver mockObserver = MockNavigatorObserver();
      Widget w = buildTestableWidgetInMaterial(
        ServerStatusWarningMessage(),
        store,
        navigator: mockObserver,
      );
      await tester.pumpWidget(w);

      expect(find.byType(Icon), findsNothing);
      expect(find.byType(RichText), findsNothing);
    });
  });
}
