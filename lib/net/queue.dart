import 'dart:async';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/store.dart';

enum NetQueueStatus {
  IDLE,
  RUNNING,
}

typedef void NetQueuePeriodicTriggerFunc();
typedef Future<bool> NetQueueActionFunc(Store<AppState> state, {String uuid});

class NetQueue {
  NetQueueStatus _status = NetQueueStatus.IDLE;
  int _stamp;
  Timer _checker;
  Map<QueueItemType, Map<QueueItemAction, NetQueueActionFunc>> _actions = Map();
  List<NetQueuePeriodicTriggerFunc> _triggers = List();

  // init queue to listen redux changed
  NetQueue() {
    getStore().onChange.listen((event) {
      if (event.queue.tick != _stamp) {
        _stamp = event.queue.tick;
        if (_status == NetQueueStatus.IDLE) {
          _queueLoop();
        }
      }
    });

    if (getStore().state.queue.now != null) {
      _queueLoop();
    }

    _sleep();
  }

  void _sleep() {
    if (_checker != null) {
      if (_checker.isActive) {
        _checker.cancel();
      }
    }
    _checker = Timer(
      Duration(seconds: 60),
      () {
        if (_status == NetQueueStatus.IDLE) {
          _periodicPushEvents();
          _queueLoop();
        }
      },
    );
  }

  void _periodicPushEvents() {
    Queue queue = getStore().state.queue;
    if (queue.list.length == 0 && queue.now == null) {
      _triggers.forEach((element) {
        element();
      });
    }
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

  void registerPeriodicTrigger(NetQueuePeriodicTriggerFunc func) {
    _triggers.add(func);
  }

  void registerQueueItemAction(
    QueueItemType type,
    QueueItemAction act,
    NetQueueActionFunc func,
  ) {
    if (_actions[type] == null) {
      _actions[type] = Map();
    }
    _actions[type][act] = func;
  }

  // wait a while until run again
  Future<bool> _executeQueueItem(Store<AppState> store, QueueItem item) async {
    if (_actions[item.type] != null &&
        _actions[item.type][item.action] != null) {
      return await _actions[item.type]
          [item.action](getStore(), uuid: item.uuid);
    }
    return true;
  }

  void _queueLoop() {
    _status = NetQueueStatus.RUNNING;
    Queue q = getStore().state.queue;
    if (q.now != null) {
      // process current one
      _executeQueueItem(getStore(), q.now).then((bool succ) {
        if (succ) {
          // if succ, remove first one and run again
          getStore().dispatch(DoneQueueItemAction());
        } else {
          // failed, to sleep and try again later
          _sleep();
        }
        _status = NetQueueStatus.IDLE;
      });
    } else {
      if (q.list.length > 0) {
        getStore().dispatch(ProcessQueueItemAction());
      } else {
        _sleep();
      }
      _status = NetQueueStatus.IDLE;
    }
  }
}

NetQueue _netQueue;

NetQueue getNetQueue() {
  if (_netQueue == null) {
    _netQueue = NetQueue();
  }
  return _netQueue;
}

setNetQueue(NetQueue netQueue) {
  _netQueue = netQueue;
}
