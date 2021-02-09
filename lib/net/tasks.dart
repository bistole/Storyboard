import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/queue.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/task.dart';

class NetTasks {
  // required
  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  // required
  ActTasks _actTasks;
  void setActTasks(ActTasks actTasks) {
    _actTasks = actTasks;
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
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      int ts = (store.state.photoRepo.lastTS + 1);
      final response = await _httpClient.get(
        prefix + "/tasks?ts=$ts&c=$countPerFetch",
        headers: {headerNameClientID: getClientID(store)},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['tasks'] != null) {
          var taskMap = buildTaskMap(object['tasks']);
          store.dispatch(FetchTasksAction(taskMap: taskMap));

          if (taskMap.length == countPerFetch) {
            _actTasks.actFetchTasks();
          }
        }
        handleNetworkSucc(store);
        return true;
      }
    } catch (e) {
      print("netFetchTasks failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netCreateTask(Store<AppState> store, {uuid: String}) async {
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Task task = store.state.taskRepo.tasks[uuid];
      if (task == null) return true;

      final response = await _httpClient.post(prefix + "/tasks",
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: jsonEncode(task.toJson()),
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(UpdateTaskAction(task: task));
        }
        handleNetworkSucc(store);
        return true;
      }
    } catch (e) {
      print("netCreateTask failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netUpdateTask(Store<AppState> store, {uuid: String}) async {
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Task task = store.state.taskRepo.tasks[uuid];
      if (task == null) return true;

      final body = jsonEncode(task.toJson());
      final response = await _httpClient.post(prefix + "/tasks/" + task.uuid,
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(UpdateTaskAction(task: task));
        }
        handleNetworkSucc(store);
        return true;
      }
    } catch (e) {
      print("netUpdateTask failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netDeleteTask(Store<AppState> store, {uuid: String}) async {
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Task task = store.state.taskRepo.tasks[uuid];
      if (task == null) return true;

      final responseStream = await _httpClient.send(
        http.Request("DELETE", Uri.parse(prefix + "/tasks/" + task.uuid))
          ..headers[headerNameClientID] = getClientID(store)
          ..body = jsonEncode({"updatedAt": task.updatedAt}),
      );

      final body = await responseStream.stream.bytesToString();

      if (responseStream.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(DeleteTaskAction(uuid: task.uuid));
        }
        handleNetworkSucc(store);
        return true;
      }
    } catch (e) {
      print("netDeleteTask failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }
}
