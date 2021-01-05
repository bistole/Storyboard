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
  Set<String> removeUuids = Set();
  Map<String, Task> updatedTasks = Map();
  action.taskMap.forEach((uuid, task) {
    if (task.deleted == 1) {
      removeUuids.add(uuid);
    } else {
      updatedTasks[uuid] = task;
    }
  });

  return Map.unmodifiable(
    Map.from(tasks)
      ..addAll(updatedTasks)
      ..removeWhere((uuid, task) => removeUuids.contains(uuid)),
  );
}

Map<String, Task> _createTask(
  Map<String, Task> tasks,
  CreateTaskAction action,
) {
  return Map.unmodifiable(
    Map.from(tasks)..addAll({action.task.uuid: action.task}),
  );
}

Map<String, Task> _updateTask(
  Map<String, Task> tasks,
  UpdateTaskAction action,
) {
  return Map.unmodifiable(
    tasks.map((uuid, task) =>
        MapEntry(uuid, uuid == action.task.uuid ? action.task : task)),
  );
}

Map<String, Task> _deleteTask(
  Map<String, Task> tasks,
  DeleteTaskAction action,
) {
  return Map.unmodifiable(
    Map.from(tasks)..remove(action.uuid),
  );
}
