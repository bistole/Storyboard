import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';

import '../../../common.dart';

class MockCommandChannel extends Mock implements CommandChannel {}

class MockNetQueue extends Mock implements NetQueue {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  MockDeviceManager dm;
  group("HomePage", () {
    MockCommandChannel mcc;
    MockMenuChannel mc;
    setUp(() {
      // mock import photo
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");

      mcc = MockCommandChannel();
      when(mcc.importPhoto()).thenAnswer((_) => Future.value(resourcePath));
      when(mcc.takePhoto()).thenAnswer((_) => Future.value(resourcePath));
      getViewResource().command = mcc;

      dm = MockDeviceManager();
      getViewResource().deviceManager = dm;

      mc = MockMenuChannel();
      getViewResource().menu = mc;
    });

    group('desktop', () {
      setUp(() {
        when(dm.isDesktop()).thenReturn(true);
        when(dm.isMobile()).thenReturn(false);
      });

      testWidgets('click button', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();

        var store = getMockStore();
        var widget = buildTestableWidget(
          HomePage(title: 'title'),
          store,
          navigator: naviObserver,
        );
        await tester.pumpWidget(widget);

        // Find button here
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('ADD PHOTO'), findsOneWidget);

        // Tap button
        await tester.tap(find.text('ADD PHOTO'));
        await tester.pump();

        verify(mcc.importPhoto()).called(1);

        // Page pushed
        var c = verify(naviObserver.didPush(captureAny, any)).captured.last
            as MaterialPageRoute;
        expect(c.settings.name, CreatePhotoPage.routeName);
      });

      testWidgets('click menu', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();

        var store = getMockStore();
        var widget = buildTestableWidget(
          HomePage(title: 'title'),
          store,
          navigator: naviObserver,
        );
        await tester.pumpWidget(widget);

        var c = verify(mc.listenAction(captureAny, captureAny)).captured;
        expect(c[0] as String, MENU_IMPORT_PHOTO);

        // callback
        await c[1]();

        verify(mcc.importPhoto()).called(1);

        // Page pushed
        var c2 = verify(naviObserver.didPush(captureAny, any)).captured.last
            as MaterialPageRoute;
        expect(c2.settings.name, CreatePhotoPage.routeName);
      });
    });
    group('Mobile', () {
      setUp(() {
        when(dm.isDesktop()).thenReturn(false);
        when(dm.isMobile()).thenReturn(true);
      });

      testWidgets('click button', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();

        var store = getMockStore();
        var widget = buildTestableWidget(
          HomePage(title: 'title'),
          store,
          navigator: naviObserver,
        );
        await tester.pumpWidget(widget);

        // Find button
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('TAKE PHOTO'), findsOneWidget);

        // Tap button
        await tester.tap(find.text('TAKE PHOTO'));
        await tester.pump();

        verify(mcc.takePhoto()).called(1);

        // pushed
        var c = verify(naviObserver.didPush(captureAny, any)).captured.last
            as MaterialPageRoute;
        expect(c.settings.name, CreatePhotoPage.routeName);
      });
    });
  });
}
