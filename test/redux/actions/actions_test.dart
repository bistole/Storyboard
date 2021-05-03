import 'package:flutter_test/flutter_test.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';

void main() {
  final note = Note.fromJson({
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
    'direction': 180,
    'hasOrigin': 'PhotoStatus.None',
    'hasThumb': 'PhotoStatus.None',
    'deleted': 1,
    'updatedAt': 1000,
    'createdAt': 1000,
    '_ts': 1000000,
  });
  test("FetchNotesAction", () {
    final act = FetchNotesAction(noteMap: {"uuid": note});
    expect(act.toString(),
        "FetchNotesAction{noteMap: {uuid: Note{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}}");
  });

  test("CreateNoteAction", () {
    final act = CreateNoteAction(note: note);
    expect(act.toString(),
        "CreateNoteAction{note: Note{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}");
  });

  test("UpdateNoteAction", () {
    final act = UpdateNoteAction(note: note);
    expect(act.toString(),
        "UpdateNoteAction{note: Note{uuid: uuid, title: title, deleted: 0, updatedAt: 1000, createdAt: 1000}}");
  });

  test("DeleteNoteAction", () {
    final act = DeleteNoteAction(uuid: "uuid");
    expect(act.toString(), "DeleteNoteAction{uuid: uuid}");
  });

  test("FetchPhotosAction", () {
    final act = FetchPhotosAction(photoMap: {});
    expect(act.toString(), "FetchPhotosAction{photoMap: {}}");
  });

  test("CreatePhotoAction", () {
    final act = CreatePhotoAction(photo: photo);
    expect(act.toString(),
        "CreatePhotoAction{photo: Photo{uuid: uuid, filename: image.jpeg, mime: image/jpeg, size: 100, direction: 180, hasOrigin: PhotoStatus.None, hasThumb: PhotoStatus.None, deleted: 1, updatedAt: 1000, createdAt: 1000}}");
  });

  test("DownloadPhotoAction", () {
    final act = DownloadPhotoAction(uuid: "uuid", status: PhotoStatus.Ready);
    expect(act.toString(),
        "DownloadPhotoAction{uuid: uuid, status: PhotoStatus.Ready}");
  });

  test("ThumbnailPhotoAction", () {
    final act = ThumbnailPhotoAction(uuid: "uuid", status: PhotoStatus.Ready);
    expect(act.toString(),
        "ThumbnailPhotoAction{uuid: uuid, status: PhotoStatus.Ready}");
  });

  test("UpdatePhotoAction", () {
    final act = UpdatePhotoAction(photo: photo);
    expect(act.toString(),
        "UpdatePhotoAction{photo: Photo{uuid: uuid, filename: image.jpeg, mime: image/jpeg, size: 100, direction: 180, hasOrigin: PhotoStatus.None, hasThumb: PhotoStatus.None, deleted: 1, updatedAt: 1000, createdAt: 1000}}");
  });

  test("DeletePhotoAction", () {
    final act = DeletePhotoAction(uuid: "uuid");
    expect(act.toString(), "DeletePhotoAction{uuid: uuid}");
  });

  test("ChangeStatusAction", () {
    final act = ChangeStatusAction(status: StatusKey.AddingNote);
    expect(act.toString(), "ChangeStatusAction{status: StatusKey.AddingNote}");
  });

  test("ChangeStatusWithUUIDAction", () {
    final act =
        ChangeStatusWithUUIDAction(status: StatusKey.AddingNote, uuid: 'uuid');
    expect(act.toString(),
        "ChangeStatusWithUUIDAction{status: StatusKey.AddingNote, uuid: uuid}");
  });

  test("ChangeStatusWithPathAction", () {
    final act =
        ChangeStatusWithPathAction(status: StatusKey.AddingNote, path: 'path');
    expect(act.toString(),
        "ChangeStatusWithPathAction{status: StatusKey.AddingNote, path: path}");
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
        type: QueueItemType.Note, action: QueueItemAction.Create, uuid: 'uuid');
    expect(act.toString(),
        "UnshiftQueueItemAction{type: QueueItemType.Note, action: QueueItemAction.Create, uuid: uuid}");
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
