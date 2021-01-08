import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:storyboard/storage/storage.dart';

import '../common.dart';

void main() {
  const root = "./project_home";
  setUp(() {
    getStorage().dataHome = root;
  });

  test("getPersistDataPath", () {
    expect(getStorage().getPersistDataPath(), path.join(root, 'state.json'));
  });

  test("getPersistDataPath", () {
    expect(
      getStorage().getPhotoPathByUUID('uuu'),
      path.join(root, 'photos/uuu'),
    );
  });

  test("getPersistDataPath", () {
    expect(
      getStorage().getThumbnailPathByUUID('uuu'),
      path.join(root, 'thumbnails/uuu'),
    );
  });

  test("copyPhotoByUUID", () async {
    await getStorage().initPhotoStorage();

    String resourcePath = getResourcePath("test_resources/photo_test.jpg");
    await getStorage().copyPhotoByUUID('uuu', File(resourcePath));
    expect(File(path.join(root, 'photos', 'uuu')).existsSync(), true);

    await Directory(path.join(root)).delete(recursive: true);
  });

  test("savePhotoByUUID", () async {
    await getStorage().initPhotoStorage();
    await getStorage().savePhotoByUUID('uuu', Uint8List.fromList([10, 20, 30]));
    expect(File(path.join(root, 'photos', 'uuu')).existsSync(), true);

    await getStorage().deletePhotoAndThumbByUUID('uuu');
    expect(File(path.join(root, 'photos', 'uuu')).existsSync(), false);

    await Directory(path.join(root)).delete(recursive: true);
  });

  test("savePhotoByUUID", () async {
    await getStorage().initPhotoStorage();
    await getStorage()
        .saveThumbailByUUID('uuu', Uint8List.fromList([10, 20, 30]));
    expect(File(path.join(root, 'thumbnails', 'uuu')).existsSync(), true);

    await getStorage().deletePhotoAndThumbByUUID('uuu');
    expect(File(path.join(root, 'photos', 'uuu')).existsSync(), false);

    await Directory(path.join(root)).delete(recursive: true);
  });
}
