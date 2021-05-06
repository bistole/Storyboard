import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/notes.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/redux/models/note_repo.dart';

import '../common.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockActNotes extends Mock implements ActNotes {}

var mockHostname = "192.168.3.146";
var mockPort = 3000;
var mockServerKey = encodeServerKey(mockHostname, mockPort);
var mockURLPrefix = 'http://' + mockHostname + ":" + mockPort.toString();

void main() {
  Store<AppState> store;
  MockHttpClient httpClient;
  ActNotes actNotes;
  NetNotes netNotes;

  setUp(() {
    setFactoryLogger(MockLogger());
  });

  buildStore(Map<String, Note> notes) {
    getFactory().store = store = getMockStore(
      nr: NoteRepo(notes: notes, lastTS: 0),
      setting: Setting(
        serverKey: mockServerKey,
      ),
    );
  }

  getJsonNoteObject() {
    return {
      'uuid': 'uuid',
      'title': 'title of note',
      'deleted': 0,
      'updatedAt': 1606506017,
      'createdAt': 1606506017,
      '_ts': 1606506017000,
    };
  }

  Note getNoteObject() {
    return Note(
      uuid: 'uuid',
      title: 'title of note',
      deleted: 0,
      updatedAt: 1606506017,
      createdAt: 1606506017,
      ts: 1606506017000,
    );
  }

  group("netFetchNotes", () {
    setUp(() {
      httpClient = MockHttpClient();
      actNotes = MockActNotes();
      netNotes = NetNotes();
      netNotes.setLogger(MockLogger());
      netNotes.setHttpClient(httpClient);
      netNotes.setActNotes(actNotes);
    });

    test("fetch new note", () async {
      // no photo existed
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'notes': [getJsonNoteObject()],
      });
      when(httpClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed("headers"),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netFetchNotes(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed("headers")))
              .captured
              .first;
      expect((captured as Uri).toString(), mockURLPrefix + '/notes?ts=1&c=100');

      expect(store.state.noteRepo.notes, {'uuid': getNoteObject()});
    });

    test('fetch existed note', () async {
      buildStore({
        'uuid': getNoteObject().copyWith(
          updatedAt: 1600000000,
          createdAt: 1600000000,
          ts: 1600000000000,
        )
      });

      final responseBody = jsonEncode({
        'succ': true,
        'notes': [getJsonNoteObject()],
      });

      when(httpClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed("headers"),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netFetchNotes(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed("headers")))
              .captured
              .first;
      expect((captured as Uri).toString(), mockURLPrefix + '/notes?ts=1&c=100');

      expect(store.state.noteRepo.notes, {
        'uuid': getNoteObject(),
      });
    });

    test('fetch deleting note', () async {
      buildStore({'uuid': getNoteObject()});

      final responseBody = jsonEncode({
        'succ': true,
        'notes': [
          getJsonNoteObject()..addAll({'deleted': 1})
        ],
      });

      when(httpClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed("headers"),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netFetchNotes(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed("headers")))
              .captured
              .first;
      expect((captured as Uri).toString(), mockURLPrefix + '/notes?ts=1&c=100');

      expect(store.state.noteRepo.notes, {});
    });

    test("no retry", () async {
      var savedCountPerFetch = countPerFetch;
      countPerFetch = 2;
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'notes': [getJsonNoteObject()],
      });
      when(httpClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed("headers"),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netFetchNotes(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed("headers")))
              .captured
              .first;
      expect((captured as Uri).toString(), mockURLPrefix + '/notes?ts=1&c=2');

      verifyNever(actNotes.actFetchNotes());

      countPerFetch = savedCountPerFetch;
    });

    test("retry", () async {
      var savedCountPerFetch = countPerFetch;
      countPerFetch = 2;
      buildStore({});

      final responseBody = jsonEncode({
        'succ': true,
        'notes': [
          getJsonNoteObject(),
          getJsonNoteObject()..addAll({'uuid': 'uuid2'}),
        ],
      });
      when(httpClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed("headers"),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netFetchNotes(store);

      var captured =
          verify(httpClient.get(captureAny, headers: anyNamed("headers")))
              .captured
              .first;
      expect((captured as Uri).toString(), mockURLPrefix + '/notes?ts=1&c=2');

      verify(actNotes.actFetchNotes()).called(1);

      countPerFetch = savedCountPerFetch;
    });
  });

  group('netCreateNote', () {
    setUp(() {
      httpClient = MockHttpClient();
      actNotes = MockActNotes();
      netNotes = NetNotes();
      netNotes.setLogger(MockLogger());
      netNotes.setHttpClient(httpClient);
      netNotes.setActNotes(actNotes);
    });

    test("create succ", () async {
      // no photo existed
      buildStore({'uuid': getNoteObject().copyWith(ts: 0)});

      final responseBody = jsonEncode({
        'succ': true,
        'note': getJsonNoteObject(),
      });

      when(httpClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netCreateNote(store, uuid: 'uuid');

      var captured = verify(httpClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).captured;

      expect((captured[0] as Uri).toString(), mockURLPrefix + '/notes');
      expect(captured[1]['Content-Type'], 'application/json');
      expect(captured[2], jsonEncode(getNoteObject().copyWith(ts: 0).toJson()));

      expect(store.state.noteRepo.notes['uuid'].ts, 1606506017000);
    });
  });

  group('netUpdateNote', () {
    setUp(() {
      httpClient = MockHttpClient();
      actNotes = MockActNotes();
      netNotes = NetNotes();
      netNotes.setLogger(MockLogger());
      netNotes.setHttpClient(httpClient);
      netNotes.setActNotes(actNotes);
    });

    test('update succ', () async {
      buildStore({'uuid': getNoteObject().copyWith(ts: 1606500000000)});

      final responseBody = jsonEncode({
        'succ': true,
        'note': getJsonNoteObject(),
      });

      when(httpClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).thenAnswer((_) async {
        return http.Response(responseBody, 200);
      });

      await netNotes.netUpdateNote(store, uuid: 'uuid');

      var captured = verify(httpClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
        encoding: Encoding.getByName('utf-8'),
      )).captured;

      expect((captured[0] as Uri).toString(), mockURLPrefix + '/notes/uuid');
      expect(captured[1]['Content-Type'], 'application/json');
      expect(captured[2],
          jsonEncode(getNoteObject().copyWith(ts: 1606500000000).toJson()));

      expect(store.state.noteRepo.notes['uuid'].ts, 1606506017000);
    });
  });

  group('netDeleteNote', () {
    setUp(() {
      httpClient = MockHttpClient();
      actNotes = MockActNotes();
      netNotes = NetNotes();
      netNotes.setLogger(MockLogger());
      netNotes.setHttpClient(httpClient);
      netNotes.setActNotes(actNotes);
    });

    test('delete succ', () async {
      buildStore({'uuid': getNoteObject()});

      final responseBody = jsonEncode({
        'succ': true,
        'note': getJsonNoteObject()..addAll({'deleted': 1}),
      });
      when(httpClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value(utf8.encode(responseBody)), 200);
      });

      await netNotes.netDeleteNote(store, uuid: 'uuid');

      var capHttp =
          verify(httpClient.send(captureAny)).captured.first as http.Request;
      expect(capHttp.method, 'DELETE');
      expect(capHttp.url.toString(), mockURLPrefix + '/notes/uuid');
      expect(capHttp.body, jsonEncode({"updatedAt": 1606506017}));

      expect(store.state.noteRepo.notes['uuid'], isNull);
    });
  });
}
