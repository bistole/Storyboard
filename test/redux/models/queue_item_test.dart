import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/queue_item.dart';

main() {
  test('status hashcode', () {
    var item = QueueItem(
        type: QueueItemType.Task, action: QueueItemAction.Create, uuid: "uuid");
    var copiedItem = item.copyWith(uuid: 'otherUUID');

    expect(item == copiedItem, false);
    expect(item.hashCode, isNotNull);
  });
}
