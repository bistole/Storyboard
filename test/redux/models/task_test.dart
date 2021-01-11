import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/task.dart';

main() {
  test('task hashcode', () {
    var task = Task(
      uuid: 'uuid',
      title: 'new title',
    );

    expect(task.hashCode, isNotNull);
  });
}
