import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

import '../common.dart';

main() {
  Store<AppState> store;

  setUp(() {
    setFactoryLogger(MockLogger());
  });

  buildStore(Queue queue) {
    getFactory().store = store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListNote),
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        noteRepo: NoteRepo(notes: {}, lastTS: 0),
        queue: queue,
      ),
    );
  }

  test('addQueueItem|addBeforeQueueItem', () async {
    buildStore(Queue(list: [], tick: 1));

    NetQueue netQueue = NetQueue(60);
    netQueue.setLogger(MockLogger());
    netQueue.setStore(store);
    netQueue.start();

    List<String> order = [];
    Future<bool> callback(Store<AppState> state, {uuid: String}) async {
      order.add(uuid);
      return true;
    }

    netQueue.registerQueueItemAction(
        QueueItemType.Note, QueueItemAction.Create, callback);
    netQueue.addQueueItem(
      QueueItemType.Note,
      QueueItemAction.Create,
      'uuid-no1',
    );
    netQueue.addBeforeQueueItem(
      QueueItemType.Note,
      QueueItemAction.Create,
      'uuid-before',
    );
    netQueue.addQueueItem(
      QueueItemType.Note,
      QueueItemAction.Create,
      'uuid-no2',
    );

    await Future.delayed(Duration(seconds: 1));
    expect(order, ['uuid-before', 'uuid-no1', 'uuid-no2']);
  });

  // test('registerPeriodicTrigger', () async {
  //   buildStore(Queue(list: [], tick: 1));

  //   bool callbackWorks = false;
  //   void callback() {
  //     callbackWorks = true;
  //   }

  //   NetQueue netQueue = NetQueue(1);
  //   netQueue.setStore(store);
  //   netQueue.start();

  //   netQueue.registerPeriodicTrigger(callback);

  //   await Future.delayed(Duration(milliseconds: 100));
  //   expect(callbackWorks, false);
  //   await Future.delayed(Duration(seconds: 1));
  //   expect(callbackWorks, true);
  // });
}
