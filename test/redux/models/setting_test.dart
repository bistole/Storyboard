import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/setting.dart';

void main() {
  group('Setting', () {
    test('copyWith', () {
      var s = Setting();
      var s2 = s.copyWith();

      expect(s == s2, true);
      expect(s2.hashCode, isNotNull);
    });
  });
}
