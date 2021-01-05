import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';

import '../actions/actions.dart';

final queueReducer = combineReducers<Queue>([
  TypedReducer<Queue, PushQueueItemAction>(_pushQueueItem),
  TypedReducer<Queue, UnshiftQueueItemAction>(_unshiftQueueItem),
  TypedReducer<Queue, ProcessQueueItemAction>(_processQueueItem),
  TypedReducer<Queue, DoneQueueItemAction>(_doneQueueItem),
]);

Queue _pushQueueItem(Queue queue, PushQueueItemAction action) {
  return queue.push(
      QueueItem(type: action.type, action: action.action, uuid: action.uuid));
}

Queue _unshiftQueueItem(Queue queue, UnshiftQueueItemAction action) {
  return queue.unshift(
      QueueItem(type: action.type, action: action.action, uuid: action.uuid));
}

Queue _processQueueItem(Queue queue, ProcessQueueItemAction action) {
  return queue.process();
}

Queue _doneQueueItem(Queue queue, DoneQueueItemAction action) {
  return queue.done();
}
