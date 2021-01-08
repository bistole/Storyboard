import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/task.dart';

final taskReducer = combineReducers<Map<String, Task>>([
  TypedReducer<Map<String, Task>, FetchTasksAction>(_fetchTasks),
  TypedReducer<Map<String, Task>, CreateTaskAction>(_createTask),
  TypedReducer<Map<String, Task>, UpdateTaskAction>(_updateTask),
  TypedReducer<Map<String, Task>, DeleteTaskAction>(_deleteTask),
]);

Map<String, Task> _fetchTasks(
  Map<String, Task> tasks,
  FetchTasksAction action,
) {
  Map<String, Task> newTasks = Map();
  Map<String, Task> existedTasks = Map();
  Set<String> removeUuids = Set();

  action.taskMap.forEach((uuid, element) {
    if (tasks[uuid] == null) {
      if (element.deleted == 0) {
        newTasks[uuid] = element;
      }
    } else if (element.deleted == 0) {
      existedTasks[uuid] = element;
    } else {
      removeUuids.add(element.uuid);
    }
  });

  // merge
  return Map.from(tasks).map((uuid, task) =>
      MapEntry(uuid, existedTasks[uuid] != null ? existedTasks[uuid] : task))
    ..addAll(newTasks)
    ..removeWhere((uuid, task) => removeUuids.contains(uuid));
}

Map<String, Task> _createTask(
  Map<String, Task> tasks,
  CreateTaskAction action,
) {
  return Map.from(tasks)..addAll({action.task.uuid: action.task});
}

Map<String, Task> _updateTask(
  Map<String, Task> tasks,
  UpdateTaskAction action,
) {
  return Map.from(tasks).map((uuid, task) =>
      MapEntry(uuid, uuid == action.task.uuid ? action.task : task));
}

Map<String, Task> _deleteTask(
  Map<String, Task> tasks,
  DeleteTaskAction action,
) {
  return Map.from(tasks)..remove(action.uuid);
}
