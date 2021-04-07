import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/menu_notifier.dart';
import 'package:storyboard/logger/logger.dart';

import '../common.dart';

void main() {
  group('MenuNotifier', () {
    test('add notify remove succ', () {
      MenuNotifier mn = MenuNotifier(logger: MockLogger());

      var called = false;
      VoidCallback func = () {
        called = true;
      };

      mn.addListener('event_id', func);
      var has = mn.hasListeners('event_id');
      mn.notifyListeners('event_id');
      mn.removeListener('event_id', func);

      expect(has, true);
      expect(called, true);
    });

    test('err in callback', () {
      Logger logger = MockLogger();
      MenuNotifier mn = MenuNotifier(logger: logger);
      VoidCallback func = () {
        throw Exception('error');
      };

      mn.addListener('event_id', func);
      mn.notifyListeners('event_id');

      verify(logger.error(any, any)).called(1);
    });

    test('dispose menu item notifier', () {
      MenuNotifier mn = MenuNotifier(logger: MockLogger());
      mn.dispose();
      mn.hasListeners('event_id');
    });
  });
}