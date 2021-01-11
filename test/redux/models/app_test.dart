import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';

void main() {
  getListStatus() {
    return Status(status: StatusKey.ListTask);
  }

  getAddTaskStatus() {
    return Status(status: StatusKey.AddingTask, param1: 'uuid');
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
        'uuid': {
          'uuid': 'uuid',
          'title': 'new title',
          'deleted': 0,
          'createdAt': 12000,
          'updatedAt': 14000,
          'ts': 14000000,
        }
      },
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
          "tasks: {uuid: Task{uuid: uuid, title: new title, deleted: 0, updatedAt: 14000, createdAt: 12000}}, " +
          "photos: {uuid: Photo{uuid: uuid, filename: file.jpeg, mime: image/jpeg, size: 3000, hasOrigin: false, hasThumb: false, deleted: 0, updatedAt: 14000, createdAt: 12000}}, " +
          "queue: Queue{list: [QueueItem{type: null, action: null, uuid: uuid}], tick: 12, now: QueueItem{type: null, action: null, uuid: uuid}}}",
    );
  });

  test("appState toJson", () {
    AppState app = AppState(
      status: getListStatus(),
      photos: {'uuid': getPhoto()},
      tasks: {'uuid': getTask()},
      queue: Queue(
        tick: 12,
        now: getCreateQueue(),
        list: [getCreateQueue()],
      ),
    );

    expect(app.toJson(), {
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
        }
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
      photos: {},
      tasks: {},
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
