import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/note_repo.dart';

import '../actions/actions.dart';
import '../models/note.dart';

final noteReducer = combineReducers<NoteRepo>([
  TypedReducer<NoteRepo, FetchNotesAction>(_fetchNotes),
  TypedReducer<NoteRepo, CreateNoteAction>(_createNote),
  TypedReducer<NoteRepo, UpdateNoteAction>(_updateNote),
  TypedReducer<NoteRepo, DeleteNoteAction>(_deleteNote),
]);

NoteRepo _fetchNotes(
  NoteRepo noteRepo,
  FetchNotesAction action,
) {
  Map<String, Note> newNotes = Map();
  Map<String, Note> existedNotes = Map();
  Set<String> removeUuids = Set();

  int lastTS = noteRepo.lastTS;

  action.noteMap.forEach((uuid, element) {
    if (noteRepo.notes[uuid] == null) {
      if (element.deleted == 0) {
        newNotes[uuid] = element;
      }
    } else if (element.deleted == 0) {
      existedNotes[uuid] = element;
    } else {
      removeUuids.add(element.uuid);
    }
    if (element.ts > lastTS) {
      lastTS = element.ts;
    }
  });

  // merge
  return noteRepo.copyWith(
    notes: Map.from(noteRepo.notes).map((uuid, note) =>
        MapEntry(uuid, existedNotes[uuid] != null ? existedNotes[uuid] : note))
      ..addAll(newNotes)
      ..removeWhere((uuid, note) => removeUuids.contains(uuid)),
    lastTS: lastTS,
  );
}

NoteRepo _createNote(
  NoteRepo noteRepo,
  CreateNoteAction action,
) {
  return noteRepo.copyWith(
    notes: Map.from(noteRepo.notes)..addAll({action.note.uuid: action.note}),
  );
}

NoteRepo _updateNote(
  NoteRepo noteRepo,
  UpdateNoteAction action,
) {
  return noteRepo.copyWith(
    notes: Map.from(noteRepo.notes).map((uuid, note) =>
        MapEntry(uuid, uuid == action.note.uuid ? action.note : note)),
  );
}

NoteRepo _deleteNote(
  NoteRepo noteRepo,
  DeleteNoteAction action,
) {
  return noteRepo.copyWith(
    notes: Map.from(noteRepo.notes)..remove(action.uuid),
  );
}
