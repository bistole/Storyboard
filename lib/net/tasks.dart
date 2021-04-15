import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/queue.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/task.dart';

class NetTasks {
  String _logTag = (NetTasks).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

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
    _logger.info(_logTag, "netFetchTasks");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      int ts = (store.state.photoRepo.lastTS + 1);
      _logger.debug(_logTag, "req: null");

      final response = await _httpClient.get(
        prefix + "/tasks?ts=$ts&c=$countPerFetch",
        headers: {headerNameClientID: getClientID(store)},
      );

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netFetchTasks succ");
        _logger.debug(_logTag, "body: ${response.body}");
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
      } else {
        _logger.warn(
            _logTag, "netFetchTasks failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body: ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netFetchTasks failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netCreateTask(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netCreateTask");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Task task = store.state.taskRepo.tasks[uuid];
      if (task == null) return true;

      var body = jsonEncode(task.toJson());
      _logger.debug(_logTag, "req: $body");

      final response = await _httpClient.post(prefix + "/tasks",
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netCreateTask succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(UpdateTaskAction(task: task));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netCreateTask failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body: ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netCreateTask failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netUpdateTask(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netUpdateTask");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Task task = store.state.taskRepo.tasks[uuid];
      if (task == null) return true;

      final body = jsonEncode(task.toJson());
      _logger.debug(_logTag, "req: $body");

      final response = await _httpClient.post(prefix + "/tasks/" + task.uuid,
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netUpdateTask succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(UpdateTaskAction(task: task));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netUpdateTask failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body: ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netUpdateTask failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netDeleteTask(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netDeleteTask");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Task task = store.state.taskRepo.tasks[uuid];
      if (task == null) return true;

      _logger.debug(_logTag, "req: null");

      final responseStream = await _httpClient.send(
        http.Request("DELETE", Uri.parse(prefix + "/tasks/" + task.uuid))
          ..headers[headerNameClientID] = getClientID(store)
          ..body = jsonEncode({"updatedAt": task.updatedAt}),
      );

      final body = await responseStream.stream.bytesToString();

      if (responseStream.statusCode == 200) {
        _logger.info(_logTag, "netDeleteTask succ");
        _logger.debug(_logTag, "body: $body");
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['task'] != null) {
          var task = Task.fromJson(object['task']);
          store.dispatch(DeleteTaskAction(uuid: task.uuid));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(_logTag,
            "netUpdateTask failed: remote: ${responseStream.statusCode}");
        _logger.debug(_logTag, "body: $body");
      }
    } catch (e) {
      _logger.warn(_logTag, "netDeleteTask failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }
}
