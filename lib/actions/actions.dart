import 'package:storyboard/models/status.dart';
import 'package:storyboard/models/task.dart';

class FetchTasksAction {
  final List<Task> taskList;

  FetchTasksAction({this.taskList});

  @override
  String toString() {
    return 'FetchTasksAction{taskList: $taskList}';
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
  final Task task;

  DeleteTaskAction({this.task});

  @override
  String toString() {
    return 'DeleteTaskAction{task: $task}';
  }
}

class ChangeStatusAction {
  final StatusKey status;

  ChangeStatusAction({this.status});

  @override
  String toString() {
    return 'ChangeStatusAction{status: $status}';
  }
}

class ChangeStatusWithUUIDAction {
  final StatusKey status;
  final String uuid;

  ChangeStatusWithUUIDAction({this.status, this.uuid});

  @override
  String toString() {
    return 'ChangeStatusWithUUIDAction{status: $status, uuid: $uuid}';
  }
}
