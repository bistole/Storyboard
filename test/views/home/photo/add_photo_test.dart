import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/channel/notifier.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';

import '../../../common.dart';
import '../../../helper/route_aware_widget.dart';

class MockCommandChannel extends Mock implements CommandChannel {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockMenuChannel extends Mock implements MenuChannel {}

class MockNotifier extends Mock implements Notifier {}

void main() {
  String resourcePath;
  MockDeviceManager dm;
  group("HomePage", () {
    MockCommandChannel mcc;
    MockMenuChannel mc;
    MockNotifier mnf;

    setUp(() {
      // mock import photo
      resourcePath = getResourcePath("test_resources/photo_test.jpg");

      mcc = MockCommandChannel();
      when(mcc.importPhoto()).thenAnswer((_) => Future.value(resourcePath));
      when(mcc.takePhoto()).thenAnswer((_) => Future.value(resourcePath));
      getViewResource().command = mcc;

      dm = MockDeviceManager();
      getViewResource().deviceManager = dm;

      mc = MockMenuChannel();
      getViewResource().menu = mc;

      mnf = MockNotifier();
      getViewResource().notifier = mnf;
    });

    group('desktop', () {
      setUp(() {
        when(dm.isDesktop()).thenReturn(true);
        when(dm.isMobile()).thenReturn(false);
      });

      testWidgets('click button', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();
        setRouteObserver(naviObserver);

        await mockImageHelper(tester, resourcePath);

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
        await tester.pumpAndSettle();

        verify(mcc.importPhoto()).called(1);
        // Page pushed
        var c = verify(naviObserver.didPush(captureAny, any)).captured.last
            as MaterialPageRoute;
        expect(c.settings.name, CreatePhotoPage.routeName);
      });

      testWidgets('click menu', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();
        setRouteObserver(naviObserver);

        await mockImageHelper(tester, resourcePath);

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

      testWidgets('click take photo', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();
        setRouteObserver(naviObserver);

        await mockImageHelper(tester, resourcePath);

        var store = getMockStore();
        var widget = buildTestableWidget(
          HomePage(title: 'title'),
          store,
          navigator: naviObserver,
        );
        await tester.pumpWidget(widget);

        // Find button
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('ADD PHOTO'), findsOneWidget);

        // Tap button
        await tester.tap(find.text('ADD PHOTO'));
        await tester.pumpAndSettle();

        // show popup
        expect(find.text('Take Photo'), findsOneWidget);
        expect(find.text('Import from Album'), findsOneWidget);

        // Tap 'Take Photo'
        await tester.tap(find.text('Take Photo'));
        await tester.pumpAndSettle();

        verify(mcc.takePhoto()).called(1);

        // pushed
        var c = verify(naviObserver.didPush(captureAny, any)).captured.last
            as MaterialPageRoute;
        expect(c.settings.name, CreatePhotoPage.routeName);
      });

      testWidgets('click import from album', (WidgetTester tester) async {
        NavigatorObserver naviObserver = MockNavigatorObserver();
        setRouteObserver(naviObserver);

        await mockImageHelper(tester, resourcePath);

        var store = getMockStore();
        var widget = buildTestableWidget(
          HomePage(title: 'title'),
          store,
          navigator: naviObserver,
        );
        await tester.pumpWidget(widget);

        // Find button
        expect(find.byType(SBToolbarButton), findsNWidgets(1));
        expect(find.text('ADD PHOTO'), findsOneWidget);

        // Tap button
        await tester.tap(find.text('ADD PHOTO'));
        await tester.pumpAndSettle();

        // show popup
        expect(find.text('Take Photo'), findsOneWidget);
        expect(find.text('Import from Album'), findsOneWidget);

        // Tap 'Take Photo'
        await tester.tap(find.text('Import from Album'));
        await tester.pumpAndSettle();

        verify(mcc.importPhotoFromAlbum()).called(1);

        // poped
        verify(naviObserver.didPop(any, any)).called(1);
      });
    });
  });
}
