import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/redux/models/queue_item.dart';

import '../common.dart';

void main() {
  test('actFetchPhotos', () {
    var netQueue = MockNetQueue();
    var actNotes = ActNotes();
    actNotes.setNetQueue(netQueue);

    actNotes.actFetchNotes();

    var capture =
        verify(netQueue.addQueueItem(captureAny, captureAny, null)).captured;
    expect(capture[0], QueueItemType.Note);
    expect(capture[1], QueueItemAction.List);
  });
}
