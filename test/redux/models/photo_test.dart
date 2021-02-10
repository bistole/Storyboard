import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/photo.dart';

main() {
  test('photo hashcode', () {
    var photo = Photo(
      uuid: 'uuid',
      filename: 'file.png',
      mime: 'image/png',
      size: '10000',
    );

    expect(photo.hashCode, isNotNull);
  });
}
