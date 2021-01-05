import 'package:flutter_test/flutter_test.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';

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
    final act = FetchTasksAction(taskMap: {"uuid": task});
    expect(act.toString(),
        "FetchTasksAction{taskMap: {uuid: Task{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}}");
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
    final act = DeleteTaskAction(uuid: "uuid");
    expect(act.toString(), "DeleteTaskAction{uuid: uuid}");
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
