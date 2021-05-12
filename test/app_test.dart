import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/views/root/app.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/logger/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';
import 'package:storyboard/views/photo/photo_page.dart';
import 'package:storyboard/views/root/app_wrapper.dart';

import 'common.dart';

class MockFactory extends Mock implements Factory {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  group('app', () {
    testWidgets('factory not available', (WidgetTester tester) async {
      // not available
      await tester.pumpWidget(StoryBoardAppWrapper());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('factory available', (WidgetTester tester) async {
      Factory fact = MockFactory();
      ViewsResource vr = MockViewResource();
      DeviceManager dm = MockDeviceManager();
      MenuChannel mc = MockMenuChannel();

      when(fact.store).thenAnswer((_) => getMockStore());
      when(dm.isDesktop()).thenReturn(true);
      when(dm.isMobile()).thenReturn(false);
      when(fact.deviceManager).thenReturn(dm);
      setFactory(fact);

      when(vr.deviceManager).thenReturn(dm);
      when(vr.menu).thenReturn(mc);
      when(vr.isWiderLayout(any)).thenReturn(true);
      setViewResource(vr);

      await tester.pumpWidget(StoryBoardAppWrapper());

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('route', () {
    test('home page', () {
      var route = StoryBoardApp.onGenerateRoute(
          RouteSettings(name: HomePage.routeName));
      expect(route.settings.name, HomePage.routeName);

      var w = route.builder(null);
      expect(w.runtimeType, HomePage);
    });

    test('create photo page', () {
      var route = StoryBoardApp.onGenerateRoute(RouteSettings(
          name: CreatePhotoPage.routeName,
          arguments: CreatePhotoPageArguments('path')));
      expect(route.settings.name, CreatePhotoPage.routeName);

      var w = route.builder(null);
      expect(w.runtimeType, CreatePhotoPage);
      expect((w as CreatePhotoPage).args.path, 'path');
    });

    test('photo page', () {
      var route = StoryBoardApp.onGenerateRoute(RouteSettings(
          name: PhotoPage.routeName,
          arguments: PhotoPageArguments('uuid', 90)));
      expect(route.settings.name, PhotoPage.routeName);

      var w = route.builder(null);
      expect(w.runtimeType, PhotoPage);
      expect((w as PhotoPage).args.uuid, 'uuid');
      expect((w as PhotoPage).args.direction, 90);
    });

    test('auth page', () {
      var route = StoryBoardApp.onGenerateRoute(
          RouteSettings(name: AuthPage.routeName));
      expect(route.settings.name, AuthPage.routeName);

      var w = route.builder(null);
      expect(w.runtimeType, AuthPage);
    });

    test('logger page', () {
      var route = StoryBoardApp.onGenerateRoute(
          RouteSettings(name: LoggerPage.routeName));
      expect(route.settings.name, LoggerPage.routeName);

      var w = route.builder(null);
      expect(w.runtimeType, LoggerPage);
    });
  });
}
