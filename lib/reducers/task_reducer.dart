import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/task.dart';

final taskReducer = combineReducers<List<Task>>([
  TypedReducer<List<Task>, FetchTasksAction>(_fetchTasks),
  TypedReducer<List<Task>, CreateTaskAction>(_createTask),
  TypedReducer<List<Task>, UpdateTaskAction>(_updateTask),
  TypedReducer<List<Task>, DeleteTaskAction>(_deleteTask),
]);

List<Task> _fetchTasks(List<Task> tasks, FetchTasksAction action) {
  return action.tasks;
}

List<Task> _createTask(List<Task> tasks, CreateTaskAction action) {
  return List.from(tasks)..add(action.task);
}

List<Task> _updateTask(List<Task> tasks, UpdateTaskAction action) {
  return tasks
      .map((task) => task.uuid == action.task.uuid ? action.task : task);
}

List<Task> _deleteTask(List<Task> tasks, DeleteTaskAction action) {
  return tasks.where((task) => task.uuid != action.uuid).toList();
}
