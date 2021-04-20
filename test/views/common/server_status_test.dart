import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/server_status.dart';
import 'package:storyboard/views/config/config.dart';

import '../../common.dart';

class MockBackendChannel extends Mock implements BackendChannel {}

main() {
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

    getFactory().store = store = getMockStore();
  });

  testWidgets('init and tap', (WidgetTester tester) async {
    NavigatorObserver mockObserver = MockNavigatorObserver();
    Widget w =
        buildTestableWidget(ServerStatus(), store, navigator: mockObserver);
    await tester.pumpWidget(w);

    await tester.tap(find.ancestor(
        of: find.byIcon(AppIcons.qrcode),
        matching: find.byWidgetPredicate((widget) => widget is TextButton)));
    await tester.pumpAndSettle();

    var capture = verify(mockObserver.didPush(captureAny, any)).captured;
    expect((capture[0] as MaterialPageRoute).settings.name, '/');
    expect((capture[1] as MaterialPageRoute).settings.name, AuthPage.routeName);

    expect(find.byType(AuthPage), findsOneWidget);
  });
}
