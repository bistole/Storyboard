import 'package:storyboard/redux/models/note.dart';

class NoteRepo {
  final Map<String, Note> notes;
  final int lastTS;

  NoteRepo({this.notes, this.lastTS});

  NoteRepo copyWith({Map<String, Note> notes, int lastTS}) {
    return NoteRepo(
      notes: notes ?? this.notes,
      lastTS: lastTS ?? this.lastTS,
    );
  }

  @override
  int get hashCode => notes.hashCode ^ lastTS.hashCode;

  @override
  bool operator ==(Object other) {
    var same = identical(this, other) ||
        (other is NoteRepo && notes == other.notes && lastTS == other.lastTS);
    return same;
  }

  @override
  String toString() {
    return "NoteRepo{notes: $notes, lastTS: $lastTS}";
  }

  factory NoteRepo.fromJson(Map<String, dynamic> json) {
    var notes = <String, Note>{};
    if (json is Map && json['notes'] is Map) {
      json['notes'].forEach((uuid, jsonNote) {
        var note = Note.fromJson(jsonNote);
        notes[note.uuid] = note;
      });
    }

    int lastTS = 0;
    if (json is Map && json['ts'] is int) {
      lastTS = json['ts'];
    }

    return NoteRepo(
      notes: notes,
      lastTS: lastTS,
    );
  }

  Map<String, dynamic> toJson() {
    var jsonNotes = {};
    notes.forEach((uuid, note) {
      jsonNotes[uuid] = note.toJson();
    });

    Map<String, dynamic> json = {};
    json['ts'] = lastTS;
    json['notes'] = jsonNotes;

    return json;
  }
}
