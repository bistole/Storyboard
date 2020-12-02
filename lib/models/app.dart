import 'package:Storyboard/models/status.dart';
import 'package:flutter/material.dart';
import 'task.dart';

@immutable
class AppState {
  final Status status;
  final Map<String, Task> tasks;

  AppState({
    this.status,
    this.tasks = const <String, Task>{},
  });

  AppState copyWith({
    Status status,
    Map<String, Task> tasks,
  }) {
    return AppState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  int get hashCode => status.hashCode ^ tasks.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState && status == other.status && tasks == other.tasks);

  @override
  String toString() {
    return 'AppState{status: $status, tasks: $tasks}';
  }

  static AppState fromJson(dynamic json) {
    var tasks = <String, Task>{};
    if (json is Map && json['tasks'] is Map) {
      json['tasks'].forEach((uuid, jsonTask) {
        var task = Task.fromJson(jsonTask);
        tasks[task.uuid] = task;
      });
    }
    return AppState(status: Status.noParam(StatusKey.ListTask), tasks: tasks);
  }

  dynamic toJson() {
    Map<String, dynamic> ret = <String, dynamic>{};
    tasks.forEach((uuid, task) {
      ret[uuid] = task.toJson();
    });
    return {"tasks": tasks};
  }
}
