import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/logger/logger.dart';

class MockLogger extends Mock implements Logger {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockCommandChannel extends Mock implements CommandChannel {}

void main() {
  test('menu', () async {
    MethodChannel mc = MockMethodChannel();
    CommandChannel commandC = MockCommandChannel();

    MenuChannel menuC = MenuChannel(mc);
    menuC.setCommandChannel(commandC);
    menuC.setLogger(MockLogger());

    var captured = verify(mc.setMethodCallHandler(captureAny)).captured.single;
    expect(captured, menuC.notifyMenuEvent);

    menuC.notifyMenuEvent(MethodCall('MENU_EVENTS:IMPORT_PHOTO'));
    verify(commandC.importPhoto()).called(1);

    menuC.notifyMenuEvent(MethodCall('TIMER', 'test current timestamp'));
  });
}
