import 'dart:async';
import 'dart:convert';
import 'package:Storyboard/actions/actions.dart';
import 'package:Storyboard/models/app.dart';
import 'package:redux/redux.dart';

import '../net/config.dart';
import '../models/task.dart';

Future<void> fetchTasks(Store<AppState> store) async {
  final response = await getHTTPClient().get(URLPrefix + "/tasks");

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['tasks'] != null) {
      var taskList = buildTaskList(object['tasks']);
      store.dispatch(new FetchTasksAction(taskList: taskList));
    }
  }
}

Future<void> createTask(Store<AppState> store, String title) async {
  final body = jsonEncode({"title": title});
  final response = await getHTTPClient().post(URLPrefix + "/tasks",
      headers: {'Content-Type': 'application/json'},
      body: body,
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['task'] != null) {
      var task = Task.fromJson(object['task']);
      store.dispatch(new CreateTaskAction(task: task));
    }
  }
}

Future<void> updateTask(Store<AppState> store, Task task) async {
  final body = jsonEncode(task.toJson());
  final response = await getHTTPClient().post(URLPrefix + "/tasks/" + task.uuid,
      headers: {'Content-Type': 'application/json'},
      body: body,
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['task'] != null) {
      var task = Task.fromJson(object['task']);
      store.dispatch(new UpdateTaskAction(task: task));
    }
  }
}

Future<void> deleteTask(Store<AppState> store, Task task) async {
  final response =
      await getHTTPClient().delete(URLPrefix + "/tasks/" + task.uuid);

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['task'] != null) {
      var task = Task.fromJson(object['task']);
      store.dispatch(new DeleteTaskAction(task: task));
    }
  }
}
