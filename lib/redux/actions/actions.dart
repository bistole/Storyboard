import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';

class FetchTasksAction {
  final Map<String, Task> taskMap;

  FetchTasksAction({this.taskMap});

  @override
  String toString() {
    return 'FetchTasksAction{taskMap: $taskMap}';
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

class FetchPhotosAction {
  final Map<String, Photo> photoMap;

  FetchPhotosAction({this.photoMap});

  @override
  String toString() {
    return 'FetchPhotosAction{photoMap: $photoMap}';
  }
}

class CreatePhotoAction {
  final Photo photo;

  CreatePhotoAction({this.photo});

  @override
  String toString() {
    return 'CreatePhotoAction{photo: $photo}';
  }
}

class DownloadPhotoAction {
  final String uuid;

  DownloadPhotoAction({this.uuid});

  @override
  String toString() {
    return 'DownloadPhotoAction{uuid: $uuid}';
  }
}

class ThumbnailPhotoAction {
  final String uuid;

  ThumbnailPhotoAction({this.uuid});

  @override
  String toString() {
    return 'ThumbnailPhotoAction{uuid: $uuid}';
  }
}

class UpdatePhotoAction {
  final Photo photo;

  UpdatePhotoAction({this.photo});

  @override
  String toString() {
    return 'UpdatePhotoAction{photo: $photo}';
  }
}

class DeletePhotoAction {
  final String uuid;

  DeletePhotoAction({this.uuid});

  @override
  String toString() {
    return 'DeletePhotoAction{uuid: $uuid}';
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

class ChangeStatusWithPathAction {
  final StatusKey status;
  final String path;

  ChangeStatusWithPathAction({this.status, this.path});

  @override
  String toString() {
    return 'ChangeStatusWithPathAction{status: $status, path: $path}';
  }
}

class PushQueueItemAction {
  final QueueItemType type;
  final QueueItemAction action;
  final String uuid;

  PushQueueItemAction({this.type, this.action, this.uuid});

  @override
  String toString() {
    return 'PushQueueItemAction{type: $type, action: $action, uuid: $uuid}';
  }
}

class UnshiftQueueItemAction {
  final QueueItemType type;
  final QueueItemAction action;
  final String uuid;

  UnshiftQueueItemAction({this.type, this.action, this.uuid});

  @override
  String toString() {
    return 'UnshiftQueueItemAction{type: $type, action: $action, uuid: $uuid}';
  }
}

class ProcessQueueItemAction {
  ProcessQueueItemAction();

  @override
  String toString() {
    return 'ProcessQueueItemAction{}';
  }
}

class DoneQueueItemAction {
  DoneQueueItemAction();

  @override
  String toString() {
    return 'DoneQueueItemAction{}';
  }
}
