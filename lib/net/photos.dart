import 'dart:convert';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/queue.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/storage/storage.dart';

var validMimeTypes = ["image/jpeg", "image/png", "image/gif"];

class NetPhotos {
  // reqiired
  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  // required
  Storage _storage;
  void setStorage(Storage storage) {
    _storage = storage;
  }

  void registerToQueue(NetQueue netQueue) {
    netQueue.registerQueueItemAction(
      QueueItemType.Photo,
      QueueItemAction.List,
      netFetchPhotos,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Photo,
      QueueItemAction.DownloadPhoto,
      netDownloadPhoto,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Photo,
      QueueItemAction.DownloadThumbnail,
      netDownloadThumbnail,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Photo,
      QueueItemAction.Upload,
      netUploadPhoto,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Photo,
      QueueItemAction.Delete,
      netDeletePhoto,
    );
  }

  Future<bool> netFetchPhotos(Store<AppState> store, {uuid: String}) async {
    try {
      final response = await _httpClient.get(URLPrefix + "/photos");
      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['photos'] != null) {
          var photoMap = buildPhotoMap(object['photos']);
          for (var photo in photoMap.values) {
            if (photo.deleted == 1) {
              await _storage.deletePhotoAndThumbByUUID(photo.uuid);
            }
          }
          store.dispatch(FetchPhotosAction(photoMap: photoMap));
        }
        return true;
      }
    } catch (e) {
      print("netFetchPhotos failed: $e");
    }
    return false;
  }

  Future<bool> netUploadPhoto(Store<AppState> store, {uuid: String}) async {
    try {
      Photo photo = store.state.photos[uuid];
      if (photo == null) return true;

      final response = await _httpClient.send(
        http.MultipartRequest("POST", Uri.parse(URLPrefix + "/photos"))
          ..fields['uuid'] = photo.uuid
          ..fields['createdAt'] = photo.createdAt.toString()
          ..files.add(
            await http.MultipartFile.fromPath(
              'photo',
              _storage.getPhotoPathByUUID(uuid),
              filename: photo.filename,
              contentType: MediaType.parse(photo.mime),
            ),
          ),
      );

      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['photo'] != null) {
          var photo = Photo.fromJson(object['photo']);
          store.dispatch(UpdatePhotoAction(photo: photo));
        }
        return true;
      }
    } catch (e) {
      print("netUploadPhoto failed: $e");
    }
    return false;
  }

  Future<bool> netDownloadPhoto(Store<AppState> store, {uuid: String}) async {
    try {
      Photo photo = store.state.photos[uuid];
      if (photo == null) return true;
      if (photo.hasOrigin) return true;

      final response = await _httpClient.get(
        URLPrefix + "/photos/" + uuid,
      );

      if (response.statusCode == 200) {
        await _storage.savePhotoByUUID(uuid, response.bodyBytes);
        store.dispatch(DownloadPhotoAction(uuid: uuid));
        return true;
      }
    } catch (e) {
      print("netDownloadPhoto failed: $e");
    }
    return false;
  }

  Future<bool> netDownloadThumbnail(Store<AppState> store,
      {uuid: String}) async {
    try {
      Photo photo = store.state.photos[uuid];
      if (photo == null) return true;
      if (photo.hasThumb) return true;

      final response = await _httpClient.get(
        URLPrefix + "/photos/" + uuid + '/thumbnail',
      );

      if (response.statusCode == 200) {
        await _storage.saveThumbailByUUID(uuid, response.bodyBytes);
        store.dispatch(ThumbnailPhotoAction(uuid: uuid));
        return true;
      }
    } catch (e) {
      print("netDownloadThumbnail failed: $e");
    }
    return false;
  }

  Future<bool> netDeletePhoto(Store<AppState> store, {uuid: String}) async {
    try {
      Photo photo = store.state.photos[uuid];
      if (photo == null) return true;

      final responseStream = await _httpClient.send(
        http.Request("DELETE", Uri.parse(URLPrefix + "/photos/" + photo.uuid))
          ..body = jsonEncode({"updatedAt": photo.updatedAt}),
      );

      final body = await responseStream.stream.bytesToString();

      if (responseStream.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['photo'] != null) {
          var photo = Photo.fromJson(object['photo']);
          await _storage.deletePhotoAndThumbByUUID(photo.uuid);
          store.dispatch(DeletePhotoAction(uuid: photo.uuid));
        }
        return true;
      }
    } catch (e) {
      print("netDeletePhoto failed: $e");
    }
    return false;
  }
}
