import 'package:flutter_test/flutter_test.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
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

  final photo = Photo.fromJson({
    'uuid': 'uuid',
    'filename': 'image.jpeg',
    'mime': 'image/jpeg',
    'size': '100',
    'deleted': 1,
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

  test("FetchPhotosAction", () {
    final act = FetchPhotosAction(photoMap: {});
    expect(act.toString(), "FetchPhotosAction{photoMap: {}}");
  });

  test("CreatePhotoAction", () {
    final act = CreatePhotoAction(photo: photo);
    expect(act.toString(),
        "CreatePhotoAction{photo: Photo{uuid: uuid, filename: image.jpeg, mime: image/jpeg, size: 100, hasOrigin: false, hasThumb: false, deleted: 1, updatedAt: 1000, createdAt: 1000}}");
  });

  test("DownloadPhotoAction", () {
    final act = DownloadPhotoAction(uuid: "uuid", status: PhotoStatus.Ready);
    expect(act.toString(), "DownloadPhotoAction{uuid: uuid, status:Ready}");
  });

  test("ThumbnailPhotoAction", () {
    final act = ThumbnailPhotoAction(uuid: "uuid", status: PhotoStatus.Ready);
    expect(act.toString(), "ThumbnailPhotoAction{uuid: uuid, status:Ready}");
  });

  test("UpdatePhotoAction", () {
    final act = UpdatePhotoAction(photo: photo);
    expect(act.toString(),
        "UpdatePhotoAction{photo: Photo{uuid: uuid, filename: image.jpeg, mime: image/jpeg, size: 100, hasOrigin: false, hasThumb: false, deleted: 1, updatedAt: 1000, createdAt: 1000}}");
  });

  test("DeletePhotoAction", () {
    final act = DeletePhotoAction(uuid: "uuid");
    expect(act.toString(), "DeletePhotoAction{uuid: uuid}");
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

  test("ChangeStatusWithPathAction", () {
    final act =
        ChangeStatusWithPathAction(status: StatusKey.AddingTask, path: 'path');
    expect(act.toString(),
        "ChangeStatusWithPathAction{status: StatusKey.AddingTask, path: path}");
  });

  test("PushQueueItemAction", () {
    final act = PushQueueItemAction(
        type: QueueItemType.Photo,
        action: QueueItemAction.Update,
        uuid: 'uuid');
    expect(act.toString(),
        "PushQueueItemAction{type: QueueItemType.Photo, action: QueueItemAction.Update, uuid: uuid}");
  });
  test("UnshiftQueueItemAction", () {
    final act = UnshiftQueueItemAction(
        type: QueueItemType.Task, action: QueueItemAction.Create, uuid: 'uuid');
    expect(act.toString(),
        "UnshiftQueueItemAction{type: QueueItemType.Task, action: QueueItemAction.Create, uuid: uuid}");
  });
  test("ProcessQueueItemAction", () {
    final act = ProcessQueueItemAction();
    expect(act.toString(), "ProcessQueueItemAction{}");
  });
  test("DoneQueueItemAction", () {
    final act = DoneQueueItemAction();
    expect(act.toString(), "DoneQueueItemAction{}");
  });
}
