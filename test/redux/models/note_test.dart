import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/redux/models/note_repo.dart';

main() {
  group('Note', () {
    test('note hashcode', () {
      var note = Note(
        uuid: 'uuid',
        title: 'new title',
      );

      expect(note.hashCode, isNotNull);
    });
  });

  group('NoteRepo', () {
    test('copyWith', () {
      var repo = NoteRepo();
      var repo2 = repo.copyWith();
      expect(repo == repo2, true);
    });
  });
}
