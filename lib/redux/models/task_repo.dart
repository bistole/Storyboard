import 'package:storyboard/redux/models/task.dart';

class TaskRepo {
  final Map<String, Task> tasks;
  final int lastTS;

  TaskRepo({this.tasks, this.lastTS});

  TaskRepo copyWith({Map<String, Task> tasks, int lastTS}) {
    return TaskRepo(
      tasks: tasks ?? this.tasks,
      lastTS: lastTS ?? this.lastTS,
    );
  }

  @override
  int get hashCode => tasks.hashCode ^ lastTS.hashCode;

  @override
  bool operator ==(Object other) {
    var same = identical(this, other) ||
        (other is TaskRepo && tasks == other.tasks && lastTS == other.lastTS);
    return same;
  }

  @override
  String toString() {
    return "TaskRepo{tasks: $tasks, lastTS: $lastTS}";
  }

  factory TaskRepo.fromJson(Map<String, dynamic> json) {
    var tasks = <String, Task>{};
    if (json is Map && json['tasks'] is Map) {
      json['tasks'].forEach((uuid, jsonTask) {
        var task = Task.fromJson(jsonTask);
        tasks[task.uuid] = task;
      });
    }

    int lastTS = 0;
    if (json is Map && json['ts'] is int) {
      lastTS = json['ts'];
    }

    return TaskRepo(
      tasks: tasks,
      lastTS: lastTS,
    );
  }

  Map<String, dynamic> toJson() {
    var jsonTasks = {};
    tasks.forEach((uuid, task) {
      jsonTasks[uuid] = task.toJson();
    });

    Map<String, dynamic> json = {};
    json['ts'] = lastTS;
    json['tasks'] = jsonTasks;

    return json;
  }
}
