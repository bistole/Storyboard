import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';

class MockNetQueue extends Mock implements NetQueue {}

void main() {
  test('actFetchPhotos', () {
    var netQueue = MockNetQueue();
    var actTasks = ActTasks();
    actTasks.setNetQueue(netQueue);

    actTasks.actFetchTasks();

    var capture =
        verify(netQueue.addQueueItem(captureAny, captureAny, null)).captured;
    expect(capture[0], QueueItemType.Task);
    expect(capture[1], QueueItemAction.List);
  });
}
