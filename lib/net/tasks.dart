import 'dart:async';
import 'dart:convert';
import '../net/config.dart';
import '../data/tasks.dart';
import 'package:http/http.dart' as http;

Future<List<Task>> fetchTasks() async {
  final response = await http.get(URLPrefix + "/tasks");

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['tasks'] != null) {
      var tasks = buildTaskList(object['tasks']);
      return tasks;
    }
  }
  throw Exception('Failed to load tasks');
}

Future<Task> createTask(String title) async {
  final body = jsonEncode({"title": title});
  final response = await http.post(URLPrefix + "/tasks",
      headers: {'Content-Type': 'application/json'},
      body: body,
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['task'] != null) {
      var task = Task.fromJson(object['task']);
      return task;
    }
  }
  throw Exception('Failed to create task');
}

Future<Task> updateTask(Task task) async {
  final body = jsonEncode(task.toJson());
  print(body);
  final response = await http.post(URLPrefix + "/tasks/" + task.uuid,
      headers: {'Content-Type': 'application/json'},
      body: body,
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['task'] != null) {
      var task = Task.fromJson(object['task']);
      return task;
    }
  }
  throw Exception('Failed to update task');
}

Future<bool> deleteTask(Task task) async {
  final response = await http.delete(URLPrefix + "/tasks/" + task.uuid);

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true) {
      return true;
    }
  }
  throw Exception('Failed to delete task');
}
