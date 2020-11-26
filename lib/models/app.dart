import 'package:Storyboard/models/status.dart';
import 'package:flutter/material.dart';
import 'task.dart';

@immutable
class AppState {
  final Status status;
  final List<Task> tasks;

  AppState({
    this.status,
    this.tasks = const [],
  });

  AppState copyWith({
    Status status,
    List<Task> tasks,
  }) {
    return AppState(status: status, tasks: tasks);
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
    List<Task> tasks = new List();
    if (json is Map && json['tasks'] is List) {
      for (int i = 0; i < json['tasks'].length; i++) {
        tasks.add(Task.fromJson(json['tasks'][i]));
      }
    }
    return AppState(status: Status.noParam(StatusKey.ListTask), tasks: tasks);
  }

  dynamic toJson() {
    List<dynamic> ret = new List();
    for (int i = 0; i < tasks.length; i++) {
      ret.add(tasks[i].toJson());
    }
    return {"tasks": tasks};
  }
}
