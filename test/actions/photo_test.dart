import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/redux/models/queue_item.dart';

import '../common.dart';

void main() {
  test('actFetchPhotos', () {
    var netQueue = MockNetQueue();
    var actPhotos = ActPhotos();
    actPhotos.setLogger(MockLogger());
    actPhotos.setNetQueue(netQueue);

    actPhotos.actFetchPhotos();

    var capture =
        verify(netQueue.addQueueItem(captureAny, captureAny, null)).captured;
    expect(capture[0], QueueItemType.Photo);
    expect(capture[1], QueueItemAction.List);
  });
}
