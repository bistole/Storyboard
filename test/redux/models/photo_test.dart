import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';

main() {
  group('Photos', () {
    test('photo hashcode', () {
      var photo = Photo(
        uuid: 'uuid',
        filename: 'file.png',
        mime: 'image/png',
        size: '10000',
      );

      expect(photo.hashCode, isNotNull);
    });
  });

  group('PhotoRepo', () {
    test('copyWith', () {
      var repo = PhotoRepo();
      var repo2 = repo.copyWith();
      expect(repo == repo2, true);
    });
  });
}
