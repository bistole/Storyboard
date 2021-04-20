import 'dart:convert';
import 'dart:io';

import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/photos.dart';

import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/storage/storage.dart';

import '../common.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockActPhotos extends Mock implements ActPhotos {}

class MockStorage extends Mock implements Storage {}

var mockHostname = "192.168.3.146";
var mockPort = 3000;
var mockServerKey = encodeServerKey(mockHostname, mockPort);
var mockURLPrefix = 'http://' + mockHostname + ":" + mockPort.toString();

void main() {
  NetPhotos netPhotos;
  Store<AppState> store;
  MockHttpClient httpClient;
  ActPhotos actPhotos;
  Storage storage;

  setUp(() {
    setFactoryLogger(MockLogger());
  });

  buildStore(Map<String, Photo> photos) {
    getFactory().store = store = getMockStore(
      pr: PhotoRepo(photos: photos, lastTS: 0),
      setting: Setting(serverKey: mockServerKey),
    );
  }

  getJsonPhotoObject() {
    return {
      'uuid': 'uuid',
      'filename': 'file.jpeg',
      'mime': 'image/jpeg',
      'size': '8384',
      'direction': 180,
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
      hasOrigin: PhotoStatus.None,
      hasThumb: PhotoStatus.None,
      direction: 180,
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
      actPhotos = MockActPhotos();

      netPhotos = NetPhotos();
      netPhotos.setLogger(MockLogger());
      netPhotos.setHttpClient(httpClient);
      netPhotos.setActPhotos(actPhotos);
      netPhotos.setStorage(storage);
    });

    test("fetch new photo", () async {
      // no photo existed
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [getJsonPhotoObject()],
      });
      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(captured, mockURLPrefix + '/photos?ts=1&c=100');

      expect(store.state.photoRepo.photos, {'uuid': getPhotoObject()});
    });

    test('fetch existed photo', () async {
      buildStore({
        'uuid': getPhotoObject().copyWith(
          hasThumb: PhotoStatus.Ready,
          hasOrigin: PhotoStatus.Ready,
          updatedAt: 1600000000,
          createdAt: 1600000000,
          ts: 1600000000000,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [getJsonPhotoObject()],
      });

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(captured, mockURLPrefix + '/photos?ts=1&c=100');

      expect(store.state.photoRepo.photos, {
        'uuid': getPhotoObject().copyWith(
          hasThumb: PhotoStatus.Ready,
          hasOrigin: PhotoStatus.Ready,
        )
      });
    });

    test('fetch deleting photo', () async {
      buildStore({
        'uuid': getPhotoObject().copyWith(
          hasThumb: PhotoStatus.Ready,
          hasOrigin: PhotoStatus.Ready,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [
          getJsonPhotoObject()..addAll({'deleted': 1})
        ],
      });

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(captured, mockURLPrefix + '/photos?ts=1&c=100');

      expect(
          verify(storage.deletePhotoAndThumbByUUID(captureAny)).captured.single,
          'uuid');

      expect(store.state.photoRepo.photos, {});
    });

    test('no retry', () async {
      // backup
      var savedCountPerFetch = countPerFetch;
      countPerFetch = 2;
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [
          getJsonPhotoObject(),
        ],
      });
      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(captured, mockURLPrefix + '/photos?ts=1&c=2');

      verifyNever(actPhotos.actFetchPhotos());

      // restore
      countPerFetch = savedCountPerFetch;
    });

    test('retry', () async {
      // backup
      var savedCountPerFetch = countPerFetch;
      countPerFetch = 2;
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'photos': [
          getJsonPhotoObject(),
          getJsonPhotoObject()..addAll({'uuid': 'uuid2'})
        ],
      });
      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netFetchPhotos(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(captured, mockURLPrefix + '/photos?ts=1&c=2');

      verify(actPhotos.actFetchPhotos()).called(1);

      // restore
      countPerFetch = savedCountPerFetch;
    });
  });

  group('netUploadPhoto', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();
      actPhotos = MockActPhotos();

      netPhotos = NetPhotos();
      netPhotos.setLogger(MockLogger());
      netPhotos.setHttpClient(httpClient);
      netPhotos.setActPhotos(actPhotos);
    });

    test('upload succ', () async {
      netPhotos.setStorage(storage);

      buildStore({
        'uuid': getPhotoObject().copyWith(
          hasOrigin: PhotoStatus.Ready,
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

      expect(store.state.photoRepo.photos['uuid'].hasOrigin, PhotoStatus.Ready);
      expect(store.state.photoRepo.photos['uuid'].hasThumb, PhotoStatus.None);
      expect(store.state.photoRepo.photos['uuid'].ts, 1606506017000);
    });
  });

  group('netDownloadPhoto', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();
      actPhotos = MockActPhotos();

      netPhotos = NetPhotos();
      netPhotos.setLogger(MockLogger());
      netPhotos.setHttpClient(httpClient);
      netPhotos.setActPhotos(actPhotos);
      netPhotos.setStorage(storage);
    });

    test('download succ', () async {
      buildStore({'uuid': getPhotoObject()});

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response("buffer", 200);
      });

      await netPhotos.netDownloadPhoto(store, uuid: 'uuid');

      var capHttp =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(capHttp, mockURLPrefix + '/photos/uuid');

      var capStorage =
          verify(storage.savePhotoByUUID(captureAny, captureAny)).captured;

      expect(capStorage[0], 'uuid');
      expect(String.fromCharCodes(capStorage[1]), 'buffer');
      expect(store.state.photoRepo.photos['uuid'].hasOrigin, PhotoStatus.Ready);
    });
  });

  group('netDownloadThumbnail', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();
      actPhotos = MockActPhotos();

      netPhotos = NetPhotos();
      netPhotos.setLogger(MockLogger());
      netPhotos.setHttpClient(httpClient);
      netPhotos.setActPhotos(actPhotos);
      netPhotos.setStorage(storage);
    });

    test('download succ', () async {
      buildStore({'uuid': getPhotoObject()});

      when(httpClient.get(startsWith(mockURLPrefix),
              headers: anyNamed('headers')))
          .thenAnswer((_) async {
        return http.Response("buffer", 200);
      });

      await netPhotos.netDownloadThumbnail(store, uuid: 'uuid');

      var capHttp =
          verify(httpClient.get(captureAny, headers: anyNamed('headers')))
              .captured
              .first;
      expect(capHttp, mockURLPrefix + '/photos/uuid/thumbnail');

      var capStorage =
          verify(storage.saveThumbailByUUID(captureAny, captureAny)).captured;

      expect(capStorage[0], 'uuid');
      expect(String.fromCharCodes(capStorage[1]), 'buffer');
      expect(store.state.photoRepo.photos['uuid'].hasThumb, PhotoStatus.Ready);
    });
  });

  group('netUpdatePhoto', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();
      actPhotos = MockActPhotos();

      netPhotos = NetPhotos();
      netPhotos.setLogger(MockLogger());
      netPhotos.setHttpClient(httpClient);
      netPhotos.setActPhotos(actPhotos);
      netPhotos.setStorage(storage);
    });

    test('update succ', () async {
      buildStore({'uuid': getPhotoObject().copyWith(ts: 1606500000000)});

      final responseBody = jsonEncode({
        'succ': true,
        'photo': getJsonPhotoObject(),
      });

      when(httpClient.post(
        startsWith(mockURLPrefix),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netPhotos.netUpdatePhoto(store, uuid: 'uuid');

      var captured = verify(httpClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).captured;

      expect(captured[0], mockURLPrefix + '/photos/uuid');
      expect(captured[1]['Content-Type'], 'application/json');
      expect(captured[2],
          jsonEncode(getPhotoObject().copyWith(ts: 1606500000000).toJson()));

      expect(store.state.photoRepo.photos['uuid'].ts, 1606506017000);
    });
  });

  group('netDeletePhoto', () {
    setUp(() {
      httpClient = MockHttpClient();
      storage = MockStorage();
      actPhotos = MockActPhotos();

      netPhotos = NetPhotos();
      netPhotos.setLogger(MockLogger());
      netPhotos.setHttpClient(httpClient);
      netPhotos.setActPhotos(actPhotos);
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
      expect(capHttp.url.toString(), mockURLPrefix + '/photos/uuid');
      expect(capHttp.body, jsonEncode({"updatedAt": 1606506017}));

      var capStorage =
          verify(storage.deletePhotoAndThumbByUUID(captureAny)).captured;

      expect(capStorage[0], 'uuid');

      expect(store.state.photoRepo.photos['uuid'], isNull);
    });
  });
}
