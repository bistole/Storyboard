import 'package:Storyboard/models/task.dart';

class FetchTasksAction {
  final List<Task> tasks;

  FetchTasksAction({this.tasks});

  @override
  String toString() {
    return 'FetchTasksAction{tasks: $tasks}';
  }
}

class CreateTaskAction {
  final Task task;

  CreateTaskAction({this.task});

  @override
  String toString() {
    return 'CreateTaskAction{task: $task}';
  }
}

class UpdateTaskAction {
  final Task task;

  UpdateTaskAction({this.task});

  @override
  String toString() {
    return 'UpdateTaskAction{task: $task}';
  }
}

class DeleteTaskAction {
  final String uuid;

  DeleteTaskAction({this.uuid});

  @override
  String toString() {
    return 'DeleteTaskAction{uuid: $uuid}';
  }
}
