import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/app.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';

import 'common.dart';

class MockFactory extends Mock implements Factory {}

class MockViewResource extends Mock implements ViewsResource {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  group('app', () {
    testWidgets('factory not available', (WidgetTester tester) async {
      // not available
      await tester.pumpWidget(StoryBoardApp());

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

      await tester.pumpWidget(StoryBoardApp());

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
