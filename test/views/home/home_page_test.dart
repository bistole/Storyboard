import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/category_panel.dart';
import 'package:storyboard/views/home/page.dart';

import '../../common.dart';

class MockViewsResource extends Mock implements ViewsResource {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockCommandChannel extends Mock implements CommandChannel {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  ViewsResource vr;
  DeviceManager dm;
  CommandChannel cmd;
  MenuChannel menu;

  setUp(() {
    vr = MockViewsResource();
    dm = MockDeviceManager();
    cmd = MockCommandChannel();
    menu = MockMenuChannel();
    when(vr.deviceManager).thenReturn(dm);
    when(vr.command).thenReturn(cmd);
    when(vr.menu).thenReturn(menu);

    setViewResource(vr);
  });
  group('HomePage', () {
    testWidgets('not wider layout', (WidgetTester tester) async {
      when(vr.isWiderLayout(any)).thenReturn(false);
      when(dm.isMobile()).thenReturn(true);

      Store<AppState> store = getMockStore();
      Widget w = buildTestableWidget(HomePage(title: 'title'), store);
      await tester.pumpWidget(w);

      expect(find.byType(CategoryPanel), findsNothing);

      var btn = find.ancestor(
        of: find.byIcon(AppIcons.menu),
        matching: find.byWidgetPredicate((widget) => widget is TextButton),
      );

      await tester.tap(btn);
      await tester.pumpAndSettle();

      expect(find.byType(CategoryPanel), findsOneWidget);
    });

    testWidgets('wider layout', (WidgetTester tester) async {
      when(vr.isWiderLayout(any)).thenReturn(true);
      when(dm.isMobile()).thenReturn(true);

      Store<AppState> store = getMockStore();
      Widget w = buildTestableWidget(HomePage(title: 'title'), store);
      await tester.pumpWidget(w);

      expect(find.byType(CategoryPanel), findsOneWidget);
      expect(find.byIcon(AppIcons.menu), findsNothing);
    });
  });
}
