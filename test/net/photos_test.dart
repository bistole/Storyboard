import 'dart:convert';
import 'dart:io';

import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/photos.dart';

import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/storage/storage.dart';

import '../common.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockStorage extends Mock implements Storage {}

void main() {
  NetPhotos netPhotos;
  Store<AppState> store;
  MockHttpClient httpClient;
  Storage storage;

  buildStore(Map<String, Photo> photos) {
    getFactory().store = store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photoRepo: PhotoRepo(photos: photos, lastTS: 0),
        taskRepo: TaskRepo(tasks: {}, lastTS: 0),
        queue: Queue(),
      ),
    );
  }

  getJsonPhotoObject() {
    return {
      'uuid': 'uuid',
      'filename': 'file.jpeg',
      'mime': 'image/jpeg',
      'size': '8384',
      'deleted': 0,
      'updatedAt': 1606506017,
      'createdAt': 1606506017,
      '_ts': 1606506017000,
    };
  }

  Photo getPhotoObject() {
    return Photo(
      uuid: 'uuid',
      filename: 'file.jpeg',
      mime: 'image/jpeg',
      size: "8384",
      hasOrigin: false,
      hasThumb: false,
      deleted: 0,
      updatedAt: 1606506017,
      createdAt: 1606506017,
      ts: 1606506017000,
    );
  }

  group("netFetchPhotos", () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();

      netPhotos = NetPhotos();
      netPhotos.setHttpClient(httpClient);
      netPhotos.setStorage(storage);
    });

    test("fetch new photo", () async {
      // no photo existed
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [getJsonPhotoObject()],
      });
      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/photos');

      expect(store.state.photoRepo.photos, {'uuid': getPhotoObject()});
    });

    test('fetch existed photo', () async {
      buildStore({
        'uuid': getPhotoObject().copyWith(
          hasThumb: true,
          hasOrigin: true,
          updatedAt: 1600000000,
          createdAt: 1600000000,
          ts: 1600000000000,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [getJsonPhotoObject()],
      });

      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/photos');

      expect(store.state.photoRepo.photos, {
        'uuid': getPhotoObject().copyWith(
          hasThumb: true,
          hasOrigin: true,
        )
      });
    });

    test('fetch deleting photo', () async {
      buildStore({
        'uuid': getPhotoObject().copyWith(
          hasThumb: true,
          hasOrigin: true,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [
          getJsonPhotoObject()..addAll({'deleted': 1})
        ],
      });

      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured = verify(httpClient.get(captureAny)).captured.first;
      expect(captured, URLPrefix + '/photos');

      expect(
          verify(storage.deletePhotoAndThumbByUUID(captureAny)).captured.single,
          'uuid');

      expect(store.state.photoRepo.photos, {});
    });
  });

  group('netUploadPhoto', () {
    setUp(() {
      httpClient = MockHttpClient();

      netPhotos = NetPhotos();
      netPhotos.setHttpClient(httpClient);
    });

    test('upload succ', () async {
      netPhotos.setStorage(storage);

      buildStore({
        'uuid': getPhotoObject().copyWith(
          hasOrigin: true,
          ts: 0,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'photo': getJsonPhotoObject(),
      });

      when(httpClient.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          200,
        ),
      );

      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      when(storage.getPhotoPathByUUID(any)).thenReturn(resourcePath);

      await netPhotos.netUploadPhoto(store, uuid: 'uuid');

      var captured = verify(httpClient.send(captureAny)).captured.single
          as http.MultipartRequest;
      expect(captured.fields['uuid'], 'uuid');
      expect(captured.fields['createdAt'], '1606506017');
      expect(captured.files[0].field, 'photo');
      expect(captured.files[0].filename, 'file.jpeg');
      expect(captured.files[0].contentType.mimeType, 'image/jpeg');
      expect(captured.files[0].length, await File(resourcePath).length());

      expect(store.state.photoRepo.photos['uuid'].hasOrigin, true);
      expect(store.state.photoRepo.photos['uuid'].hasThumb, false);
      expect(store.state.photoRepo.photos['uuid'].ts, 1606506017000);
    });
  });

  group('netDownloadPhoto', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();

      netPhotos = NetPhotos();
      netPhotos.setHttpClient(httpClient);
      netPhotos.setStorage(storage);
    });

    test('download succ', () async {
      buildStore({'uuid': getPhotoObject()});

      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response("buffer", 200);
      });

      await netPhotos.netDownloadPhoto(store, uuid: 'uuid');

      var capHttp = verify(httpClient.get(captureAny)).captured.first;
      expect(capHttp, URLPrefix + '/photos/uuid');

      var capStorage =
          verify(storage.savePhotoByUUID(captureAny, captureAny)).captured;

      expect(capStorage[0], 'uuid');
      expect(String.fromCharCodes(capStorage[1]), 'buffer');
      expect(store.state.photoRepo.photos['uuid'].hasOrigin, true);
    });
  });

  group('netDownloadThumbnail', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();

      netPhotos = NetPhotos();
      netPhotos.setHttpClient(httpClient);
      netPhotos.setStorage(storage);
    });

    test('download succ', () async {
      buildStore({'uuid': getPhotoObject()});

      when(httpClient.get(startsWith(URLPrefix))).thenAnswer((_) async {
        return http.Response("buffer", 200);
      });

      await netPhotos.netDownloadThumbnail(store, uuid: 'uuid');

      var capHttp = verify(httpClient.get(captureAny)).captured.first;
      expect(capHttp, URLPrefix + '/photos/uuid/thumbnail');

      var capStorage =
          verify(storage.saveThumbailByUUID(captureAny, captureAny)).captured;

      expect(capStorage[0], 'uuid');
      expect(String.fromCharCodes(capStorage[1]), 'buffer');
      expect(store.state.photoRepo.photos['uuid'].hasThumb, true);
    });
  });

  group('netDeletePhoto', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();
      netPhotos.setHttpClient(httpClient);
      netPhotos.setStorage(storage);
    });

    test('delete succ', () async {
      buildStore({'uuid': getPhotoObject()});

      final responseBody = jsonEncode({
        'succ': true,
        'photo': getJsonPhotoObject()..addAll({'deleted': 1}),
      });
      when(httpClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value(utf8.encode(responseBody)), 200);
      });

      await netPhotos.netDeletePhoto(store, uuid: 'uuid');

      var capHttp =
          verify(httpClient.send(captureAny)).captured.first as http.Request;
      expect(capHttp.method, 'DELETE');
      expect(capHttp.url.toString(), URLPrefix + '/photos/uuid');
      expect(capHttp.body, jsonEncode({"updatedAt": 1606506017}));

      var capStorage =
          verify(storage.deletePhotoAndThumbByUUID(captureAny)).captured;

      expect(capStorage[0], 'uuid');

      expect(store.state.photoRepo.photos['uuid'], isNull);
    });
  });
}
