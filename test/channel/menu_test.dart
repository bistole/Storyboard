import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/factory.dart';

import '../common.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  setUp(() {
    setFactoryLogger(MockLogger());
  });

  test('menu', () async {
    var called = 0;
    var func = () {
      called++;
    };

    MethodChannel mc = MockMethodChannel();

    MenuChannel menuC = MenuChannel(mc, logger: MockLogger());
    menuC.setLogger(MockLogger());
    menuC.listenAction(MENU_IMPORT_PHOTO, func);

    var captured = verify(mc.setMethodCallHandler(captureAny)).captured.single;
    expect(captured, menuC.notifyMenuEvent);

    menuC.notifyMenuEvent(MethodCall('MENU_EVENTS:IMPORT_PHOTO'));
    var ret1 = await Future.delayed(Duration(milliseconds: 300), () => called);
    expect(ret1, 1);

    menuC.removeAction(MENU_IMPORT_PHOTO, func);
    menuC.notifyMenuEvent(MethodCall('MENU_EVENTS:IMPORT_PHOTO'));
    var ret2 = await Future.delayed(Duration(milliseconds: 300), () => called);
    expect(ret2, 1);

    menuC.notifyMenuEvent(MethodCall('TIMER', 'test current timestamp'));
  });
}
