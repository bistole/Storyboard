import 'package:flutter/material.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';

class SettingServerKeyAction {
  final String serverKey;

  SettingServerKeyAction({@required this.serverKey});

  @override
  String toString() {
    return 'SettingServerKeyAction{serverKey: $serverKey}';
  }
}

class SettingServerReachableAction {
  final bool reachable;

  SettingServerReachableAction({@required this.reachable});

  @override
  String toString() {
    return 'SettingServerReachableAction{reachable: $reachable}';
  }
}

class FetchNotesAction {
  final Map<String, Note> noteMap;

  FetchNotesAction({@required this.noteMap});

  @override
  String toString() {
    return 'FetchNotesAction{noteMap: $noteMap}';
  }
}

class CreateNoteAction {
  final Note note;

  CreateNoteAction({@required this.note});

  @override
  String toString() {
    return 'CreateNoteAction{note: $note}';
  }
}

class UpdateNoteAction {
  final Note note;

  UpdateNoteAction({@required this.note});

  @override
  String toString() {
    return 'UpdateNoteAction{note: $note}';
  }
}

class DeleteNoteAction {
  final String uuid;

  DeleteNoteAction({@required this.uuid});

  @override
  String toString() {
    return 'DeleteNoteAction{uuid: $uuid}';
  }
}

class FetchPhotosAction {
  final Map<String, Photo> photoMap;

  FetchPhotosAction({@required this.photoMap});

  @override
  String toString() {
    return 'FetchPhotosAction{photoMap: $photoMap}';
  }
}

class CreatePhotoAction {
  final Photo photo;

  CreatePhotoAction({@required this.photo});

  @override
  String toString() {
    return 'CreatePhotoAction{photo: $photo}';
  }
}

class DownloadPhotoAction {
  final String uuid;
  final PhotoStatus status;

  DownloadPhotoAction({@required this.uuid, @required this.status});

  @override
  String toString() {
    return 'DownloadPhotoAction{uuid: $uuid, status: $status}';
  }
}

class ThumbnailPhotoAction {
  final String uuid;
  final PhotoStatus status;

  ThumbnailPhotoAction({@required this.uuid, @required this.status});

  @override
  String toString() {
    return 'ThumbnailPhotoAction{uuid: $uuid, status: $status}';
  }
}

class UpdatePhotoAction {
  final Photo photo;

  UpdatePhotoAction({@required this.photo});

  @override
  String toString() {
    return 'UpdatePhotoAction{photo: $photo}';
  }
}

class DeletePhotoAction {
  final String uuid;

  DeletePhotoAction({@required this.uuid});

  @override
  String toString() {
    return 'DeletePhotoAction{uuid: $uuid}';
  }
}

class ChangeStatusAction {
  final StatusKey status;

  ChangeStatusAction({@required this.status});

  @override
  String toString() {
    return 'ChangeStatusAction{status: $status}';
  }
}

class ChangeStatusWithUUIDAction {
  final StatusKey status;
  final String uuid;

  ChangeStatusWithUUIDAction({@required this.status, @required this.uuid});

  @override
  String toString() {
    return 'ChangeStatusWithUUIDAction{status: $status, uuid: $uuid}';
  }
}

class ChangeStatusWithPathAction {
  final StatusKey status;
  final String path;

  ChangeStatusWithPathAction({@required this.status, @required this.path});

  @override
  String toString() {
    return 'ChangeStatusWithPathAction{status: $status, path: $path}';
  }
}

class PushQueueItemAction {
  final QueueItemType type;
  final QueueItemAction action;
  final String uuid;

  PushQueueItemAction(
      {@required this.type, @required this.action, @required this.uuid});

  @override
  String toString() {
    return 'PushQueueItemAction{type: $type, action: $action, uuid: $uuid}';
  }
}

class UnshiftQueueItemAction {
  final QueueItemType type;
  final QueueItemAction action;
  final String uuid;

  UnshiftQueueItemAction(
      {@required this.type, @required this.action, @required this.uuid});

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
