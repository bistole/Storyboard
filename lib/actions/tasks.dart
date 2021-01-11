import 'package:redux/redux.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:uuid/uuid.dart';

class ActTasks {
  // required
  NetQueue _netQueue;
  void setNetQueue(NetQueue netQueue) {
    _netQueue = netQueue;
  }

  void actFetchTasks() {
    _netQueue.addQueueItem(
      QueueItemType.Task,
      QueueItemAction.List,
      null,
    );
  }

  void actCreateTask(Store<AppState> store, String title) {
    String uuid = Uuid().v4();
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Task task = Task(
      uuid: uuid,
      title: title,
      deleted: 0,
      createdAt: ts,
      updatedAt: ts,
      ts: 0,
    );
    store.dispatch(CreateTaskAction(task: task));
    _netQueue.addQueueItem(
      QueueItemType.Task,
      QueueItemAction.Create,
      uuid,
    );
  }

  void actUpdateTask(Store<AppState> store, String uuid, String title) {
    Task task = store.state.taskRepo.tasks[uuid];
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Task newTask = task.copyWith(
      title: title,
      updatedAt: ts,
    );
    store.dispatch(UpdateTaskAction(task: newTask));
    _netQueue.addQueueItem(
      QueueItemType.Task,
      QueueItemAction.Update,
      uuid,
    );
  }

  void actDeleteTask(Store<AppState> store, String uuid) {
    Task task = store.state.taskRepo.tasks[uuid];
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Task newTask = task.copyWith(
      deleted: 1,
      updatedAt: ts,
    );
    store.dispatch(UpdateTaskAction(task: newTask));
    _netQueue.addQueueItem(
      QueueItemType.Task,
      QueueItemAction.Delete,
      uuid,
    );
  }
}
