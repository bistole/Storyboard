import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';

import 'package:storyboard/actions/actions.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/models/app.dart';
import 'package:storyboard/models/task.dart';

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
  final uuid = Uuid().v4();
  final ts = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final body = jsonEncode({
    "uuid": uuid,
    "title": title,
    "createdAt": ts,
  });
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
  final ts = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final responseStream = await getHTTPClient().send(
    http.Request("DELETE", Uri.parse(URLPrefix + "/tasks/" + task.uuid))
      ..body = jsonEncode({"updatedAt": ts}),
  );

  final body = await responseStream.stream.bytesToString();

  if (responseStream.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(body);
    if (object['succ'] == true && object['task'] != null) {
      var task = Task.fromJson(object['task']);
      store.dispatch(new DeleteTaskAction(task: task));
    }
  }
}
