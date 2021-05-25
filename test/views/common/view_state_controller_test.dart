import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/views/common/view_state_controller.dart';

void main() {
  group('ViewStateController', () {
    test('change value', () {
      ViewStateController vsc = ViewStateController<int>(10);
      var triggered = 0;
      var func = () {
        triggered++;
      };
      vsc.addListener(func);

      vsc.value = 20;
      expect(triggered, 1);
      expect(vsc.value, 20);

      vsc.removeListener(func);
      vsc.value = 30;
      expect(triggered, 1);
      expect(vsc.value, 30);
    });
  });
}
