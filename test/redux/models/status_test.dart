import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/status.dart';

main() {
  group('Status', () {
    test('status hashcode', () {
      var status = Status(
        status: StatusKey.ListNote,
      );

      var copiedStatus = status.copyWith(
          status: StatusKey.EditingNote, param1: 'uuid', param2: 'other uuid');

      expect(copiedStatus == status, false);
    });

    test('copyWith', () {
      var status = Status(
        status: StatusKey.ListNote,
      );

      var status2 = status.copyWith();

      expect(status == status2, true);
    });

    test('status with path', () {
      var status = Status(
        status: StatusKey.ShareInPhoto,
        param1: 'path_to_photo',
      );

      expect(status.path, 'path_to_photo');
    });

    test('status with text', () {
      var status = Status(
        status: StatusKey.ShareInNote,
        param1: 'content',
      );

      expect(status.text, 'content');
    });
  });
}
