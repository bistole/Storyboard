import 'dart:async';
import 'dart:convert';
import 'package:Storyboard/actions/actions.dart';
import 'package:Storyboard/models/app.dart';
import 'package:redux/redux.dart';

import '../net/config.dart';
import '../models/task.dart';
import 'package:http/http.dart' as http;

Future<void> fetchTasks(Store<AppState> store) async {
  final response = await http.get(URLPrefix + "/tasks");

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['tasks'] != null) {
      var tasks = buildTaskList(object['tasks']);
      store.dispatch(new FetchTasksAction(tasks: tasks));
    }
  }
}

Future<void> createTask(Store<AppState> store, String title) async {
  final body = jsonEncode({"title": title});
  final response = await http.post(URLPrefix + "/tasks",
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
  final response = await http.post(URLPrefix + "/tasks/" + task.uuid,
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
  final response = await http.delete(URLPrefix + "/tasks/" + task.uuid);

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true) {
      store.dispatch(new DeleteTaskAction(uuid: task.uuid));
    }
  }
}
