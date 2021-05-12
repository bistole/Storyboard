import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';

main() {
  group('QueueItem', () {
    test('status hashcode', () {
      var item = QueueItem(
          type: QueueItemType.Note,
          action: QueueItemAction.Create,
          uuid: "uuid");
      var copiedItem = item.copyWith(uuid: 'otherUUID');

      expect(item == copiedItem, false);
      expect(item.hashCode, isNotNull);
    });

    test('copyWith', () {
      var item = QueueItem(
        type: QueueItemType.Note,
        action: QueueItemAction.Create,
        uuid: 'uuid',
      );

      var item2 = item.copyWith();
      expect(item == item2, true);
    });
  });

  group('Queue', () {
    test('copyWith', () {
      var q = Queue();
      var q2 = q.copyWith();
      expect(q == q2, true);
    });
  });
}
