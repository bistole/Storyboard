import 'package:flutter/material.dart';
import 'task.dart';

@immutable
class AppState {
  final List<Task> tasks;

  AppState({
    this.tasks = const [],
  });

  AppState copyWith({
    List<Task> tasks,
  }) {
    return AppState(tasks: tasks);
  }

  @override
  int get hashCode => tasks.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppState && tasks == other.tasks);

  @override
  String toString() {
    return 'AppState{tasks: $tasks}';
  }

  static AppState fromJson(dynamic json) {
    List<Task> tasks = new List();
    if (json['tasks']) {
      for (int i = 0; i < json['tasks'].length; i++) {
        tasks.add(Task.fromJson(json['tasks'][i]));
      }
    }
    return AppState(tasks: tasks);
  }

  dynamic toJson() {
    List<dynamic> ret = new List();
    for (int i = 0; i < tasks.length; i++) {
      ret.add(tasks[i].toJson());
    }
    return {"tasks": tasks};
  }
}
