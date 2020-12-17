import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/actions.dart';
import 'package:storyboard/models/app.dart';
import 'package:storyboard/models/photo.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/storage/photo.dart';

var validMimeTypes = ["image/jpeg", "image/png", "image/gif"];

Future<void> fetchPhotos(Store<AppState> store) async {
  final response = await getHTTPClient().get(URLPrefix + "/photos");

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['photos'] != null) {
      var photoList = buildPhotoList(object['photos']);
      store.dispatch(new FetchPhotosAction(photoList: photoList));
    }
  }
}

Future<void> uploadPhoto(Store<AppState> store, String path) async {
  // TODO: convert to valid format in backend
  var mimeType = lookupMimeType(path);
  if (!validMimeTypes.contains(mimeType)) {
    // TODO: show error in UI
    return;
  }

  var pathComp = path.split("/");
  var filename = pathComp[pathComp.length - 1];

  final response = await getHTTPClient().post(URLPrefix + "/photos",
      headers: {
        'Content-Type': mimeType,
        'Content-Name': filename,
      },
      body: File(path).readAsBytesSync(),
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['photo'] != null) {
      var photo = Photo.fromJson(object['photo']);

      // copy to local
      await copyPhotoByUUID(photo.uuid, File(path));

      // update store
      store.dispatch(new CreatePhotoAction(photo: photo));
    }
  }
}

// TODO: put into pipeline
Future<void> downloadPhoto(Store<AppState> store, String uuid) async {
  final response = await getHTTPClient().get(
    URLPrefix + "/photos/" + uuid,
  );

  if (response.statusCode == 200) {
    // save to local
    await savePhotoByUUID(uuid, response.bodyBytes);

    // update store
    store.dispatch(new DownloadPhotoAction(uuid: uuid));
  }
}

// TODO: put into pipeline
Future<void> downloadThumbnail(Store<AppState> store, String uuid) async {
  final response = await getHTTPClient().get(
    URLPrefix + "/photos/" + uuid + '/thumbnail',
  );

  if (response.statusCode == 200) {
    // save to local
    await saveThumbailByUUID(uuid, response.bodyBytes);

    // update store
    store.dispatch(new ThumbnailPhotoAction(uuid: uuid));
  }
}

Future<void> deletePhoto(Store<AppState> store, Photo photo) async {
  final response =
      await getHTTPClient().delete(URLPrefix + "/photos/" + photo.uuid);

  if (response.statusCode == 200) {
    Map<String, dynamic> object = jsonDecode(response.body);
    if (object['succ'] == true && object['photo'] != null) {
      var photo = Photo.fromJson(object['photo']);
      // delete from local
      await deletePhotoAndThumbByUUID(photo.uuid);

      // update store
      store.dispatch(new DeletePhotoAction(photo: photo));
    }
  }
}
