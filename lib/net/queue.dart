import 'dart:async';
import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';

enum NetQueueStatus {
  IDLE,
  RUNNING,
}

typedef void NetQueuePeriodicTriggerFunc();
typedef Future<bool> NetQueueActionFunc(Store<AppState> state, {String uuid});

class NetQueue {
  String _LOG_TAG = (NetQueue).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  int sleepInterval;

  // required
  Store<AppState> _store;

  NetQueueStatus _status = NetQueueStatus.IDLE;
  int _stamp;
  Timer _checker;
  Map<QueueItemType, Map<QueueItemAction, NetQueueActionFunc>> _actions = Map();
  // init queue to listen redux changed
  NetQueue(this.sleepInterval);

  void setStore(Store<AppState> store) {
    _store = store;
  }

  void start() {
    _logger.debug(_LOG_TAG, "start");
    _store.onChange.listen((event) {
      if (event.queue.tick != _stamp) {
        _stamp = event.queue.tick;
        _logger.debug(_LOG_TAG, "queue changed, try to process");
        if (_status == NetQueueStatus.IDLE) {
          _queueLoop();
        }
      }
    });

    // run at once if queue is not empty
    if (_store.state.queue.now != null || _store.state.queue.list.length > 0) {
      _logger.debug(_LOG_TAG, "queue is not empty, start to process");
      Future.delayed(Duration(seconds: 1), _queueLoop);
    }

    _sleep();
  }

  void _sleep() {
    _logger.debug(_LOG_TAG, "sleep");
    if (_checker != null) {
      if (_checker.isActive) {
        _checker.cancel();
      }
    }
    _checker = Timer(Duration(seconds: sleepInterval), _periodicPushEvents);
  }

  void _periodicPushEvents() {
    _logger.debug(_LOG_TAG, "awake");
    if (_status == NetQueueStatus.IDLE) {
      _queueLoop();
    }
  }

  // add item to queue
  void addQueueItem(
    QueueItemType type,
    QueueItemAction action,
    String uuid,
  ) {
    _logger.info(_LOG_TAG, "addQueueItem $type $action");
    _store.dispatch(PushQueueItemAction(
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
    _logger.info(_LOG_TAG, "addBeforeQueueItem $type $action");
    _store.dispatch(UnshiftQueueItemAction(
      type: type,
      action: action,
      uuid: uuid,
    ));
  }

  void registerQueueItemAction(
    QueueItemType type,
    QueueItemAction act,
    NetQueueActionFunc func,
  ) {
    _logger.info(_LOG_TAG, "registerQueueItemAction $type $act");
    if (_actions[type] == null) {
      _actions[type] = Map();
    }
    _actions[type][act] = func;
  }

  // wait a while until run again
  Future<bool> _executeQueueItem(Store<AppState> store, QueueItem item) async {
    _logger.info(_LOG_TAG, "_executeQueueItem ${item.type} ${item.action}");
    if (_actions[item.type] != null &&
        _actions[item.type][item.action] != null) {
      return await _actions[item.type][item.action](_store, uuid: item.uuid);
    }
    return true;
  }

  void _queueLoop() {
    _status = NetQueueStatus.RUNNING;
    Queue q = _store.state.queue;
    if (q.now != null) {
      _logger.debug(_LOG_TAG, "process current one");
      // process current one
      _executeQueueItem(_store, q.now).then((bool succ) {
        if (succ) {
          _logger.debug(_LOG_TAG, "process current one succ");
          // if succ, remove first one and run again
          _store.dispatch(DoneQueueItemAction());
        } else {
          _logger.debug(_LOG_TAG, "process current one failed");
          // failed, to sleep and try again later
          _sleep();
        }
        _status = NetQueueStatus.IDLE;
      });
    } else {
      if (q.list.length > 0) {
        _logger.debug(_LOG_TAG, "move top in queue to current");
        _store.dispatch(ProcessQueueItemAction());
      } else {
        _logger.debug(_LOG_TAG, "queue is empty");
        _sleep();
      }
      _status = NetQueueStatus.IDLE;
    }
  }
}
