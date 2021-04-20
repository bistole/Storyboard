import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/notifier.dart';
import 'package:storyboard/logger/logger.dart';

import '../common.dart';

void main() {
  group('MenuNotifier', () {
    test('add notify remove succ', () {
      Notifier mn = Notifier();
      mn.setLogger(MockLogger());

      var called = false;
      VoidCallback func = () {
        called = true;
      };

      mn.registerNotifier('event_id');
      mn.addListener('event_id', func);
      var has = mn.hasListeners('event_id');
      mn.notifyListeners('event_id');
      mn.removeListener('event_id', func);

      expect(has, true);
      expect(called, true);
    });

    test('get value', () {
      Logger logger = MockLogger();
      Notifier mn = Notifier();
      mn.setLogger(logger);

      var called = 0;

      mn.registerNotifier<String>('event_id');
      mn.addListener<String>('event_id', () {
        called++;
      });

      mn.notifyListeners<String>('event_id', param: 'out');

      expect(called, 1);
      expect(mn.getValue<String>('event_id'), 'out');
    });

    test('err in callback', () {
      Logger logger = MockLogger();
      Notifier mn = Notifier();
      mn.setLogger(logger);

      VoidCallback func = () {
        throw Exception('error');
      };

      mn.registerNotifier('event_id');
      mn.addListener('event_id', func);
      mn.notifyListeners('event_id');

      verify(logger.error(any, any)).called(1);
    });

    test('dispose menu item notifier', () {
      Notifier mn = Notifier();
      mn.setLogger(MockLogger());
      mn.dispose();
      mn.hasListeners('event_id');
    });
  });
}
