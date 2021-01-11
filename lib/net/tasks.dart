import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/queue.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/task.dart';

class NetTasks {
  // reqiired
  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  void registerToQueue(NetQueue netQueue) {
    // task
    netQueue.registerQueueItemAction(
      QueueItemType.Task,
      QueueItemAction.List,
      netFetchTasks,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Task,
      QueueItemAction.Create,
      netCreateTask,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Task,
      QueueItemAction.Update,
      netUpdateTask,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Task,
      QueueItemAction.Delete,
      netDeleteTask,
    );
  }

  Future<bool> netFetchTasks(Store<AppState> store, {uuid: String}) async {
    try {
      final response = await _httpClient.get(URLPrefix + "/tasks");

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['tasks'] != null) {
          var taskMap = buildTaskMap(object['tasks']);
          store.dispatch(FetchTasksAction(taskMap: taskMap));
        }
        return true;
      }
    } catch (e) {
      print("netFetchTasks failed: $e");
    }
    return false;
  }

  Future<bool> netCreateTask(Store<AppState> store, {uuid: String}) async {
    try {
      Task task = store.state.tasks[uuid];
      if (task == null) return true;

      final response = await _httpClient.post(URLPrefix + "/tasks",
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(task.toJson()),
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(UpdateTaskAction(task: task));
        }
        return true;
      }
    } catch (e) {
      print("netCreateTask failed: $e");
    }
    return false;
  }

  Future<bool> netUpdateTask(Store<AppState> store, {uuid: String}) async {
    try {
      Task task = store.state.tasks[uuid];
      if (task == null) return true;

      final body = jsonEncode(task.toJson());
      final response = await _httpClient.post(URLPrefix + "/tasks/" + task.uuid,
          headers: {'Content-Type': 'application/json'},
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(UpdateTaskAction(task: task));
        }
        return true;
      }
    } catch (e) {
      print("netUpdateTask failed: $e");
    }
    return false;
  }

  Future<bool> netDeleteTask(Store<AppState> store, {uuid: String}) async {
    try {
      Task task = store.state.tasks[uuid];
      if (task == null) return true;

      final responseStream = await _httpClient.send(
        http.Request("DELETE", Uri.parse(URLPrefix + "/tasks/" + task.uuid))
          ..body = jsonEncode({"updatedAt": task.updatedAt}),
      );

      final body = await responseStream.stream.bytesToString();

      if (responseStream.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(DeleteTaskAction(uuid: task.uuid));
        }
        return true;
      }
    } catch (e) {
      print("netDeleteTask failed: $e");
    }
    return false;
  }
}
