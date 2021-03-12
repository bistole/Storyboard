import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:storyboard/logger/logger.dart';

class Storage {
  String _LOG_TAG = (Storage).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  String dataHome;

  void setDataHome(String _dataHome) {
    dataHome = _dataHome;
  }

  String getPersistDataPath() {
    final statePath = path.join(dataHome, 'state.json');
    _logger.debug(_LOG_TAG, "statePath: $statePath");
    return statePath;
  }

  Future<void> initPhotoStorage() async {
    _logger.info(_LOG_TAG, "initPhotoStorage");
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
    _logger.debug(_LOG_TAG, "deletePhotoAndThumbByUUID: $uuid");
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
    _logger.debug(_LOG_TAG, "copyPhotoByUUID: $uuid");
    String photoPath = getPhotoPathByUUID(uuid);
    src.copySync(photoPath);
  }

  Future<void> savePhotoByUUID(String uuid, Uint8List bytes) async {
    _logger.debug(_LOG_TAG, "savePhotoByUUID: $uuid");
    String photoPath = getPhotoPathByUUID(uuid);
    await File(photoPath).writeAsBytes(bytes);
  }

  Future<void> saveThumbailByUUID(String uuid, Uint8List bytes) async {
    _logger.debug(_LOG_TAG, "saveThumbailByUUID: $uuid");
    var photoPath = getThumbnailPathByUUID(uuid);
    await File(photoPath).writeAsBytes(bytes);
  }
}
