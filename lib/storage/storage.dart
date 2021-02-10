import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

class Storage {
  String dataHome;

  void setDataHome(String _dataHome) {
    dataHome = _dataHome;
  }

  String getPersistDataPath() {
    final statePath = path.join(dataHome, 'state.json');
    return statePath;
  }

  Future<void> initPhotoStorage() async {
    final photoDirectory = Directory(path.join(dataHome, 'photos'));
    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final thumbDirectory = Directory(path.join(dataHome, 'thumbnails'));
    if (!await thumbDirectory.exists()) {
      await thumbDirectory.create(recursive: true);
    }
  }

  String getPhotoPathByUUID(String uuid) {
    final photoPath = path.join(dataHome, 'photos', uuid);
    return photoPath;
  }

  String getThumbnailPathByUUID(String uuid) {
    final thumbnailPath = path.join(dataHome, 'thumbnails', uuid);
    return thumbnailPath;
  }

  Future<void> deletePhotoAndThumbByUUID(String uuid) async {
    final photoPath = getPhotoPathByUUID(uuid);
    final thumbPath = getThumbnailPathByUUID(uuid);

    if (await File(photoPath).exists()) {
      await File(photoPath).delete();
    }
    if (await File(thumbPath).exists()) {
      await File(thumbPath).delete();
    }
  }

  Future<void> copyPhotoByUUID(String uuid, File src) async {
    String photoPath = getPhotoPathByUUID(uuid);
    await src.copy(photoPath);
  }

  Future<void> savePhotoByUUID(String uuid, Uint8List bytes) async {
    String photoPath = getPhotoPathByUUID(uuid);
    await File(photoPath).writeAsBytes(bytes);
  }

  Future<void> saveThumbailByUUID(String uuid, Uint8List bytes) async {
    var photoPath = getThumbnailPathByUUID(uuid);
    await File(photoPath).writeAsBytes(bytes);
  }
}
