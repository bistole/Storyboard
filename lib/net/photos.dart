import 'dart:convert';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/queue.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/storage/storage.dart';

var validMimeTypes = ["image/jpeg", "image/png", "image/gif"];

class NetPhotos {
  String _logTag = (NetPhotos).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  // reqiired
  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  // required
  ActPhotos _actPhotos;
  void setActPhotos(ActPhotos actPhotos) {
    _actPhotos = actPhotos;
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
      QueueItemAction.Update,
      netUpdatePhoto,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Photo,
      QueueItemAction.Delete,
      netDeletePhoto,
    );
  }

  Future<bool> netFetchPhotos(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netFetchPhotos");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      int ts = (store.state.photoRepo.lastTS + 1);
      _logger.debug(_logTag, "req: null");

      final response = await _httpClient.get(
        prefix + "/photos?ts=$ts&c=$countPerFetch",
        headers: {headerNameClientID: getClientID(store)},
      );

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netFetchPhotos succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['photos'] != null) {
          var photoMap = buildPhotoMap(object['photos']);
          for (var photo in photoMap.values) {
            if (photo.deleted == 1) {
              await _storage.deletePhotoAndThumbByUUID(photo.uuid);
            }
          }
          store.dispatch(FetchPhotosAction(photoMap: photoMap));
          if (photoMap.length == countPerFetch) {
            _actPhotos.actFetchPhotos();
          }
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netFetchPhotos failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netFetchPhotos failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netUploadPhoto(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netUploadPhoto");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Photo photo = store.state.photoRepo.photos[uuid];
      if (photo == null) return true;

      _logger.debug(_logTag, "req: null");

      final response = await _httpClient.send(
        http.MultipartRequest("POST", Uri.parse(prefix + "/photos"))
          ..headers[headerNameClientID] = getClientID(store)
          ..fields['uuid'] = photo.uuid
          ..fields['direction'] = photo.direction.toString()
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
        _logger.info(_logTag, "netUploadPhoto succ");
        _logger.debug(_logTag, "body: $body");
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['photo'] != null) {
          var photo = Photo.fromJson(object['photo']);
          store.dispatch(UpdatePhotoAction(photo: photo));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netUploadPhoto failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body $body");
      }
    } catch (e) {
      _logger.warn(_logTag, "netUploadPhoto failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netUpdatePhoto(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netUpdatePhoto");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Photo photo = store.state.photoRepo.photos[uuid];
      if (photo == null) return true;

      final body = jsonEncode(photo.toJson());
      _logger.debug(_logTag, "req: $body");

      final response = await _httpClient.post(prefix + "/photos/" + photo.uuid,
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netUpdatePhoto succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['photo'] != null) {
          var photo = Photo.fromJson(object['photo']);
          store.dispatch(UpdatePhotoAction(photo: photo));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netUpdatePhoto failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netUpdatePhoto failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netDownloadPhoto(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netDownloadPhoto");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Photo photo = store.state.photoRepo.photos[uuid];
      if (photo == null) return true;
      if (photo.hasOrigin == PhotoStatus.Ready) return true;

      _logger.debug(_logTag, "req: null");

      final response = await _httpClient.get(
        prefix + "/photos/" + uuid,
        headers: {headerNameClientID: getClientID(store)},
      );

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netDownloadPhoto succ");
        _logger.debug(_logTag, "body: ${response.body}");
        await _storage.savePhotoByUUID(uuid, response.bodyBytes);
        store.dispatch(DownloadPhotoAction(
          uuid: uuid,
          status: PhotoStatus.Ready,
        ));
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netDownloadPhoto failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netDownloadPhoto failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netDownloadThumbnail(Store<AppState> store,
      {uuid: String}) async {
    _logger.info(_logTag, "netDownloadThumbnail");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Photo photo = store.state.photoRepo.photos[uuid];
      if (photo == null) return true;
      if (photo.hasThumb == PhotoStatus.Ready) return true;

      _logger.debug(_logTag, "req: null");

      final response = await _httpClient.get(
        prefix + "/photos/" + uuid + '/thumbnail',
        headers: {headerNameClientID: getClientID(store)},
      );

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netDownloadThumbnail succ");
        _logger.debug(_logTag, "body: ${response.body}");
        await _storage.saveThumbailByUUID(uuid, response.bodyBytes);
        store.dispatch(ThumbnailPhotoAction(
          uuid: uuid,
          status: PhotoStatus.Ready,
        ));
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(_logTag,
            "netDownloadThumbnail failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netDownloadThumbnail failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netDeletePhoto(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netDeletePhoto");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Photo photo = store.state.photoRepo.photos[uuid];
      if (photo == null) return true;

      _logger.debug(_logTag, "req: null");

      final responseStream = await _httpClient.send(
        http.Request("DELETE", Uri.parse(prefix + "/photos/" + photo.uuid))
          ..headers[headerNameClientID] = getClientID(store)
          ..body = jsonEncode({"updatedAt": photo.updatedAt}),
      );

      final body = await responseStream.stream.bytesToString();

      if (responseStream.statusCode == 200) {
        _logger.info(_logTag, "netDeletePhoto succ");
        _logger.debug(_logTag, "body: $body");
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['photo'] != null) {
          var photo = Photo.fromJson(object['photo']);
          await _storage.deletePhotoAndThumbByUUID(photo.uuid);
          store.dispatch(DeletePhotoAction(uuid: photo.uuid));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(_logTag,
            "netDeletePhoto failed: remote: ${responseStream.statusCode}");
        _logger.debug(_logTag, "body: $body");
      }
    } catch (e) {
      _logger.warn(_logTag, "netDeletePhoto failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }
}
