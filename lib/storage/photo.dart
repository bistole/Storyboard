import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:storyboard/channel/config.dart';

Future<void> initPhotoStorage() async {
  final homePage = getDataHome();
  final photoDirectory = Directory(path.join(homePage, 'photos'));
  if (!await photoDirectory.exists()) {
    await photoDirectory.create(recursive: true);
  }

  final thumbDirectory = Directory(path.join(homePage, 'thumbnails'));
  if (!await thumbDirectory.exists()) {
    await thumbDirectory.create(recursive: true);
  }
}

String getPhotoPathByUUID(String uuid) {
  final homePath = getDataHome();
  final photoPath = path.join(homePath, 'photos', uuid);
  return photoPath;
}

String getThumbnailPathByUUID(String uuid) {
  final homePath = getDataHome();
  final thumbnailPath = path.join(homePath, 'thumbnails', uuid);
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
