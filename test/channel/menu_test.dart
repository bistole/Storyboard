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
    var triggered = false;

    MethodChannel mc = MockMethodChannel();

    MenuChannel menuC = MenuChannel(mc);
    menuC.setLogger(MockLogger());
    menuC.listenAction(MENU_IMPORT_PHOTO, () {
      triggered = true;
    });

    var captured = verify(mc.setMethodCallHandler(captureAny)).captured.single;
    expect(captured, menuC.notifyMenuEvent);

    menuC.notifyMenuEvent(MethodCall('MENU_EVENTS:IMPORT_PHOTO'));
    var ret =
        await Future.delayed(Duration(milliseconds: 300), () => triggered);
    expect(ret, true);

    menuC.notifyMenuEvent(MethodCall('TIMER', 'test current timestamp'));
  });
}
