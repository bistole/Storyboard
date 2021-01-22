import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/task_repo.dart';

import '../actions/actions.dart';
import '../models/task.dart';

final taskReducer = combineReducers<TaskRepo>([
  TypedReducer<TaskRepo, FetchTasksAction>(_fetchTasks),
  TypedReducer<TaskRepo, CreateTaskAction>(_createTask),
  TypedReducer<TaskRepo, UpdateTaskAction>(_updateTask),
  TypedReducer<TaskRepo, DeleteTaskAction>(_deleteTask),
]);

TaskRepo _fetchTasks(
  TaskRepo taskRepo,
  FetchTasksAction action,
) {
  Map<String, Task> newTasks = Map();
  Map<String, Task> existedTasks = Map();
  Set<String> removeUuids = Set();

  int lastTS = taskRepo.lastTS;

  action.taskMap.forEach((uuid, element) {
    if (taskRepo.tasks[uuid] == null) {
      if (element.deleted == 0) {
        newTasks[uuid] = element;
      }
    } else if (element.deleted == 0) {
      existedTasks[uuid] = element;
    } else {
      removeUuids.add(element.uuid);
    }
    if (element.ts > lastTS) {
      lastTS = element.ts;
    }
  });

  // merge
  return taskRepo.copyWith(
    tasks: Map.from(taskRepo.tasks).map((uuid, task) =>
        MapEntry(uuid, existedTasks[uuid] != null ? existedTasks[uuid] : task))
      ..addAll(newTasks)
      ..removeWhere((uuid, task) => removeUuids.contains(uuid)),
    lastTS: lastTS,
  );
}

TaskRepo _createTask(
  TaskRepo taskRepo,
  CreateTaskAction action,
) {
  return taskRepo.copyWith(
    tasks: Map.from(taskRepo.tasks)..addAll({action.task.uuid: action.task}),
  );
}

TaskRepo _updateTask(
  TaskRepo taskRepo,
  UpdateTaskAction action,
) {
  return taskRepo.copyWith(
    tasks: Map.from(taskRepo.tasks).map((uuid, task) =>
        MapEntry(uuid, uuid == action.task.uuid ? action.task : task)),
  );
}

TaskRepo _deleteTask(
  TaskRepo taskRepo,
  DeleteTaskAction action,
) {
  return taskRepo.copyWith(
    tasks: Map.from(taskRepo.tasks)..remove(action.uuid),
  );
}
