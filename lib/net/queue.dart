import 'dart:async';

import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/net/tasks.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';

enum LoopStatus {
  IDLE,
  RUNNING,
}

LoopStatus _queueStatus = LoopStatus.IDLE;
int _queueStamp;
Timer _queueChecker;

// init queue to listen redux changed
void initQueue() {
  getStore().onChange.listen((event) {
    print("Queue : ${event.queue}");
    if (event.queue.tick != _queueStamp) {
      // need to do something
      _queueStamp = event.queue.tick;
      if (_queueStatus == LoopStatus.IDLE) {
        _queueLoop();
      }
    }
  });

  if (getStore().state.queue.now != null) {
    _queueLoop();
  }

  _sleep();
}

// add item to queue
void addQueueItem(
  QueueItemType type,
  QueueItemAction action,
  String uuid,
) {
  getStore().dispatch(PushQueueItemAction(
    type: type,
    action: action,
    uuid: uuid,
  ));
}

// add item to queue in high priority
void addBeforeQueueItem(
  QueueItemType type,
  QueueItemAction action,
  String uuid,
) {
  getStore().dispatch(UnshiftQueueItemAction(
    type: type,
    action: action,
    uuid: uuid,
  ));
}

// wait a while until run again
void _sleep() {
  if (_queueChecker != null) {
    if (_queueChecker.isActive) {
      _queueChecker.cancel();
    }
  }
  _queueChecker = Timer(
    Duration(seconds: 60),
    () {
      if (_queueStatus == LoopStatus.IDLE) {
        _periodicPushEvents();
        _queueLoop();
      }
    },
  );
}

void _periodicPushEvents() {
  Queue queue = getStore().state.queue;
  if (queue.list.length == 0 && queue.now == null) {
    actFetchPhotos(getStore());
    actFetchTasks(getStore());
  }
}

Future<bool> _executeQueueItem(Store<AppState> store, QueueItem item) async {
  print("_executeQueueItem $item");
  if (item.type == QueueItemType.Task) {
    switch (item.action) {
      case QueueItemAction.List:
        return await netFetchTasks(store);
      case QueueItemAction.Create:
        return await netCreateTask(store, item.uuid);
      case QueueItemAction.Update:
        return await netUpdateTask(store, item.uuid);
      case QueueItemAction.Delete:
        return await netDeleteTask(store, item.uuid);
      default:
    }
  } else if (item.type == QueueItemType.Photo) {
    switch (item.action) {
      case QueueItemAction.List:
        return await netFetchPhotos(store);
      case QueueItemAction.DownloadPhoto:
        return await netDownloadPhoto(store, item.uuid);
      case QueueItemAction.DownloadThumbnail:
        return netDownloadThumbnail(store, item.uuid);
      case QueueItemAction.Upload:
        return await netUploadPhoto(store, item.uuid);
      case QueueItemAction.Delete:
        return await netDeletePhoto(store, item.uuid);
      default:
    }
  }
  return true;
}

void _queueLoop() {
  _queueStatus = LoopStatus.RUNNING;
  Queue q = getStore().state.queue;
  if (q.now != null) {
    // process current one
    _executeQueueItem(getStore(), q.now).then((bool succ) {
      print("_executeQueueItem ret: $succ");
      if (succ) {
        // if succ, remove first one and run again
        getStore().dispatch(DoneQueueItemAction());
      } else {
        // failed, to sleep and try again later
        _sleep();
      }
      _queueStatus = LoopStatus.IDLE;
    });
  } else {
    if (q.list.length > 0) {
      getStore().dispatch(ProcessQueueItemAction());
    } else {
      _sleep();
    }
    _queueStatus = LoopStatus.IDLE;
  }
}
