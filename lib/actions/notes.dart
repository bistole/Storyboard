import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:uuid/uuid.dart';

class ActNotes {
  String _logTag = (ActNotes).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  // required
  NetQueue _netQueue;
  void setNetQueue(NetQueue netQueue) {
    _netQueue = netQueue;
  }

  void actFetchNotes() {
    _netQueue.addQueueItem(
      QueueItemType.Note,
      QueueItemAction.List,
      null,
    );
  }

  void actCreateNote(Store<AppState> store, String title) {
    _logger.info(_logTag, "actCreateNote");
    String uuid = Uuid().v4();
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Note note = Note(
      uuid: uuid,
      title: title,
      deleted: 0,
      createdAt: ts,
      updatedAt: ts,
      ts: 0,
    );
    store.dispatch(CreateNoteAction(note: note));
    _netQueue.addQueueItem(
      QueueItemType.Note,
      QueueItemAction.Create,
      uuid,
    );
  }

  void actUpdateNote(Store<AppState> store, String uuid, String title) {
    _logger.info(_logTag, "actUpdateNote");
    Note note = store.state.noteRepo.notes[uuid];
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Note newNote = note.copyWith(
      title: title,
      updatedAt: ts,
    );
    store.dispatch(UpdateNoteAction(note: newNote));
    _netQueue.addQueueItem(
      QueueItemType.Note,
      QueueItemAction.Update,
      uuid,
    );
  }

  void actDeleteNote(Store<AppState> store, String uuid) {
    _logger.info(_logTag, "actDeleteNote");
    Note note = store.state.noteRepo.notes[uuid];
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Note newNote = note.copyWith(
      deleted: 1,
      updatedAt: ts,
    );
    store.dispatch(UpdateNoteAction(note: newNote));
    _netQueue.addQueueItem(
      QueueItemType.Note,
      QueueItemAction.Delete,
      uuid,
    );
  }
}
