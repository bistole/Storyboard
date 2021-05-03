import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/note.dart';

main() {
  test('note hashcode', () {
    var note = Note(
      uuid: 'uuid',
      title: 'new title',
    );

    expect(note.hashCode, isNotNull);
  });
}
