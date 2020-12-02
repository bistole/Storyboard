import 'package:Storyboard/actions/actions.dart';
import 'package:Storyboard/models/status.dart';
import 'package:Storyboard/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final task = Task.fromJson({
    'uuid': 'uuid',
    'title': 'title',
    'deleted': 0,
    'updatedAt': 1000,
    'createdAt': 1000,
    '_ts': 1000000,
  });
  test("FetchTasksAction", () {
    final act = FetchTasksAction(taskList: [task]);
    expect(act.toString(),
        "FetchTasksAction{taskList: [Task{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}]}");
  });

  test("CreateTaskAction", () {
    final act = CreateTaskAction(task: task);
    expect(act.toString(),
        "CreateTaskAction{task: Task{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}");
  });

  test("UpdateTaskAction", () {
    final act = UpdateTaskAction(task: task);
    expect(act.toString(),
        "UpdateTaskAction{task: Task{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}");
  });

  test("DeleteTaskAction", () {
    final act = DeleteTaskAction(task: task);
    expect(act.toString(),
        "DeleteTaskAction{task: Task{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}");
  });

  test("ChangeStatusAction", () {
    final act = ChangeStatusAction(status: StatusKey.AddingTask);
    expect(act.toString(), "ChangeStatusAction{status: StatusKey.AddingTask}");
  });

  test("ChangeStatusWithUUIDAction", () {
    final act =
        ChangeStatusWithUUIDAction(status: StatusKey.AddingTask, uuid: 'uuid');
    expect(act.toString(),
        "ChangeStatusWithUUIDAction{status: StatusKey.AddingTask, uuid: uuid}");
  });
}
