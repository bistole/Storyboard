import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';

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

class FetchPhotosAction {
  final List<Photo> photoList;

  FetchPhotosAction({this.photoList});

  @override
  String toString() {
    return 'FetchPhotosAction{photoList: $photoList}';
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

class DeletePhotoAction {
  final Photo photo;

  DeletePhotoAction({this.photo});

  @override
  String toString() {
    return 'DeletePhotoAction{photo: $photo}';
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
