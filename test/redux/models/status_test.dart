import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/status.dart';

main() {
  test('status hashcode', () {
    var status = Status(
      status: StatusKey.ListTask,
    );

    var copiedStatus = status.copyWith(
        status: StatusKey.EditingTask, param1: 'uuid', param2: 'other uuid');

    expect(copiedStatus == status, false);
  });
}
