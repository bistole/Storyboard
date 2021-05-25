import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/redux/models/note_repo.dart';

void main() {
  getListStatus() {
    return Status(status: StatusKey.ListNote);
  }

  getPhoto() {
    return Photo(
      uuid: 'uuid',
      filename: 'image.jpeg',
      mime: 'image/jpeg',
      size: '10000',
      direction: 180,
      hasOrigin: PhotoStatus.None,
      hasThumb: PhotoStatus.Loading,
      deleted: 0,
      createdAt: 12000,
      updatedAt: 14000,
      ts: 14000000,
    );
  }

  getNote() {
    return Note(
      uuid: 'uuid',
      title: 'title',
      deleted: 0,
      createdAt: 12000,
      updatedAt: 14000,
      ts: 14000000,
    );
  }

  getCreateQueue() {
    return QueueItem(
      type: QueueItemType.Note,
      action: QueueItemAction.Create,
      uuid: 'uuid',
    );
  }

  test('appState init', () {
    var appState = AppState.initState();
    expect(
        appState.toString(),
        startsWith(
            "AppState{status: Status{status: StatusKey.ListNote, param1: null, param2: null}, " +
                "noteRepo: NoteRepo{notes: {}, lastTS: 0}, " +
                "photoRepo: PhotoRepo{photos: {}, lastTS: 0}, " +
                "queue: Queue{list: [], tick: 0, now: null}, " +
                "setting: Setting{clientID:"));
    expect(appState.toString(),
        endsWith(", serverKey: null, serverReachable: Reachable.Unknown}}"));
  });

  test("appState fromJson", () {
    var appState = AppState.fromJson({
      'notes': {
        'notes': {
          'uuid': {
            'uuid': 'uuid',
            'title': 'new title',
            'deleted': 0,
            'createdAt': 12000,
            'updatedAt': 14000,
            'ts': 14000000,
          }
        },
        'ts': 0,
      },
      'photos': {
        'photos': {
          'uuid': {
            'uuid': 'uuid',
            'filename': 'file.jpeg',
            'mime': 'image/jpeg',
            'size': '3000',
            'direction': 180,
            'hasOrigin': 'PhotoStatus.None',
            'hasThumb': 'PhotoStatus.Loading',
            'deleted': 0,
            'createdAt': 12000,
            'updatedAt': 14000,
            'ts': 14000000,
          }
        },
        'ts': 0,
      },
      'queue': {
        'now': {
          'type': 'Photo',
          'action': 'Upload',
          'uuid': 'uuid',
        },
        'list': [
          {
            'type': 'Photo',
            'action': 'Upload',
            'uuid': 'uuid',
          }
        ],
        'tick': 12
      },
      'setting': {
        'clientID': 'client-id',
        'serverKey': 'server-key',
      }
    });
    expect(
      appState.toString(),
      "AppState{status: Status{status: StatusKey.ListNote, param1: null, param2: null}, " +
          "noteRepo: NoteRepo{notes: {uuid: Note{uuid: uuid, title: new title, deleted: 0, updatedAt: 14000, createdAt: 12000}}, lastTS: 0}, " +
          "photoRepo: PhotoRepo{photos: {uuid: Photo{uuid: uuid, filename: file.jpeg, mime: image/jpeg, size: 3000, direction: 180, hasOrigin: PhotoStatus.None, hasThumb: PhotoStatus.Loading, deleted: 0, updatedAt: 14000, createdAt: 12000}}, lastTS: 0}, " +
          "queue: Queue{list: [QueueItem{type: null, action: null, uuid: uuid}], tick: 12, now: QueueItem{type: null, action: null, uuid: uuid}}, " +
          "setting: Setting{clientID: client-id, serverKey: server-key, serverReachable: Reachable.Unknown}}",
    );
  });

  test("appState toJson", () {
    AppState app = AppState(
      status: getListStatus(),
      photoRepo: PhotoRepo(photos: {'uuid': getPhoto()}, lastTS: 0),
      noteRepo: NoteRepo(notes: {'uuid': getNote()}, lastTS: 0),
      queue: Queue(
        tick: 12,
        now: getCreateQueue(),
        list: [getCreateQueue()],
      ),
      setting: Setting(
        clientID: "client-id",
        serverKey: "server-key",
        serverReachable: Reachable.Unknown,
      ),
    );

    expect(app.toJson(), {
      'notes': {
        'notes': {
          'uuid': {
            'uuid': 'uuid',
            'title': 'title',
            'deleted': 0,
            'updatedAt': 14000,
            'createdAt': 12000,
            '_ts': 14000000
          }
        },
        'ts': 0,
      },
      'photos': {
        'photos': {
          'uuid': {
            'uuid': 'uuid',
            'filename': 'image.jpeg',
            'mime': 'image/jpeg',
            'size': '10000',
            'direction': 180,
            'hasOrigin': 'PhotoStatus.None',
            'hasThumb': 'PhotoStatus.Loading',
            'deleted': 0,
            'updatedAt': 14000,
            'createdAt': 12000,
            '_ts': 14000000
          },
        },
        'ts': 0,
      },
      'queue': {
        'tick': 12,
        'now': {
          'type': 'QueueItemType.Note',
          'action': 'QueueItemAction.Create',
          'uuid': 'uuid'
        },
        'list': [
          {
            'type': 'QueueItemType.Note',
            'action': 'QueueItemAction.Create',
            'uuid': 'uuid'
          }
        ]
      },
      'setting': {
        'clientID': 'client-id',
        'serverKey': 'server-key',
      },
    });
  });

  group('copyWith', () {
    test('copyWith new queue', () {
      AppState app = AppState(
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        noteRepo: NoteRepo(notes: {}, lastTS: 0),
        status: getListStatus(),
        queue: Queue(
          tick: 1,
          list: [getCreateQueue()],
        ),
      );

      AppState app2 = app.copyWith(
        queue: app.queue.copyWith(tick: 2),
      );

      expect(app == app2, false);
      expect(app.hashCode, isNot(app2.hashCode));
    });

    test('copyWith all same', () {
      AppState app = AppState(
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        noteRepo: NoteRepo(notes: {}, lastTS: 0),
        status: getListStatus(),
        queue: Queue(tick: 1, list: [getCreateQueue()]),
      );

      AppState app2 = app.copyWith();

      expect(app == app2, true);
      expect(app.hashCode, app2.hashCode);
    });
  });
}
