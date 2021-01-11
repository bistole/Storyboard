import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/redux/models/task_repo.dart';

void main() {
  getListStatus() {
    return Status(status: StatusKey.ListTask);
  }

  getPhoto() {
    return Photo(
      uuid: 'uuid',
      filename: 'image.jpeg',
      mime: 'image/jpeg',
      size: '10000',
      deleted: 0,
      createdAt: 12000,
      updatedAt: 14000,
      ts: 14000000,
    );
  }

  getTask() {
    return Task(
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
      type: QueueItemType.Task,
      action: QueueItemAction.Create,
      uuid: 'uuid',
    );
  }

  test("appState fromJson", () {
    var appState = AppState.fromJson({
      'tasks': {
        'tasks': {
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
    });
    expect(
      appState.toString(),
      "AppState{status: Status{status: StatusKey.ListTask, param1: null, param2: null}, " +
          "taskRepo: TaskRepo{tasks: {uuid: Task{uuid: uuid, title: new title, deleted: 0, updatedAt: 14000, createdAt: 12000}}, lastTS: 0}, " +
          "photoRepo: PhotoRepo{photos: {uuid: Photo{uuid: uuid, filename: file.jpeg, mime: image/jpeg, size: 3000, hasOrigin: false, hasThumb: false, deleted: 0, updatedAt: 14000, createdAt: 12000}}, lastTS: 0}, " +
          "queue: Queue{list: [QueueItem{type: null, action: null, uuid: uuid}], tick: 12, now: QueueItem{type: null, action: null, uuid: uuid}}}",
    );
  });

  test("appState toJson", () {
    AppState app = AppState(
      status: getListStatus(),
      photoRepo: PhotoRepo(photos: {'uuid': getPhoto()}, lastTS: 0),
      taskRepo: TaskRepo(tasks: {'uuid': getTask()}, lastTS: 0),
      queue: Queue(
        tick: 12,
        now: getCreateQueue(),
        list: [getCreateQueue()],
      ),
    );

    expect(app.toJson(), {
      'tasks': {
        'tasks': {
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
            'hasOrigin': null,
            'hasThumb': null,
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
          'type': 'QueueItemType.Task',
          'action': 'QueueItemAction.Create',
          'uuid': 'uuid'
        },
        'list': [
          {
            'type': 'QueueItemType.Task',
            'action': 'QueueItemAction.Create',
            'uuid': 'uuid'
          }
        ]
      }
    });
  });

  test('copyWith', () {
    AppState app = AppState(
      photoRepo: PhotoRepo(photos: {}, lastTS: 0),
      taskRepo: TaskRepo(tasks: {}, lastTS: 0),
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
}
