import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/queue.dart';

import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/note.dart';

class NetNotes {
  String _logTag = (NetNotes).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  // required
  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  // required
  ActNotes _actNotes;
  void setActNotes(ActNotes actNotes) {
    _actNotes = actNotes;
  }

  void registerToQueue(NetQueue netQueue) {
    // note
    netQueue.registerQueueItemAction(
      QueueItemType.Note,
      QueueItemAction.List,
      netFetchNotes,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Note,
      QueueItemAction.Create,
      netCreateNote,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Note,
      QueueItemAction.Update,
      netUpdateNote,
    );
    netQueue.registerQueueItemAction(
      QueueItemType.Note,
      QueueItemAction.Delete,
      netDeleteNote,
    );
  }

  Future<bool> netFetchNotes(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netFetchNotes");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      int ts = (store.state.photoRepo.lastTS + 1);
      _logger.debug(_logTag, "req: null");

      final uri = Uri.parse(prefix + "/notes?ts=$ts&c=$countPerFetch");
      final response = await _httpClient
          .get(uri, headers: {headerNameClientID: getClientID(store)});

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netFetchNotes succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['notes'] != null) {
          var noteMap = buildNoteMap(object['notes']);
          store.dispatch(FetchNotesAction(noteMap: noteMap));

          if (noteMap.length == countPerFetch) {
            _actNotes.actFetchNotes();
          }
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netFetchNotes failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body: ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netFetchNotes failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netCreateNote(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netCreateNote");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Note note = store.state.noteRepo.notes[uuid];
      if (note == null) return true;

      var body = jsonEncode(note.toJson());
      _logger.debug(_logTag, "req: $body");

      final uri = Uri.parse(prefix + "/notes");
      final response = await _httpClient.post(uri,
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netCreateNote succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['note'] != null) {
          var note = Note.fromJson(object['note']);
          store.dispatch(UpdateNoteAction(note: note));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netCreateNote failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body: ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netCreateNote failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netUpdateNote(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netUpdateNote");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Note note = store.state.noteRepo.notes[uuid];
      if (note == null) return true;

      final body = jsonEncode(note.toJson());
      _logger.debug(_logTag, "req: $body");

      final uri = Uri.parse(prefix + "/notes/" + note.uuid);
      final response = await _httpClient.post(uri,
          headers: {
            'Content-Type': 'application/json',
            headerNameClientID: getClientID(store)
          },
          body: body,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        _logger.info(_logTag, "netUpdateNote succ");
        _logger.debug(_logTag, "body: ${response.body}");
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['succ'] == true && object['note'] != null) {
          var note = Note.fromJson(object['note']);
          store.dispatch(UpdateNoteAction(note: note));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(
            _logTag, "netUpdateNote failed: remote: ${response.statusCode}");
        _logger.debug(_logTag, "body: ${response.body}");
      }
    } catch (e) {
      _logger.warn(_logTag, "netUpdateNote failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }

  Future<bool> netDeleteNote(Store<AppState> store, {uuid: String}) async {
    _logger.info(_logTag, "netDeleteNote");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      Note note = store.state.noteRepo.notes[uuid];
      if (note == null) return true;

      _logger.debug(_logTag, "req: null");

      final responseStream = await _httpClient.send(
        http.Request("DELETE", Uri.parse(prefix + "/notes/" + note.uuid))
          ..headers[headerNameClientID] = getClientID(store)
          ..body = jsonEncode({"updatedAt": note.updatedAt}),
      );

      final body = await responseStream.stream.bytesToString();

      if (responseStream.statusCode == 200) {
        _logger.info(_logTag, "netDeleteNote succ");
        _logger.debug(_logTag, "body: $body");
        Map<String, dynamic> object = jsonDecode(body);
        if (object['succ'] == true && object['note'] != null) {
          var note = Note.fromJson(object['note']);
          store.dispatch(DeleteNoteAction(uuid: note.uuid));
        }
        handleNetworkSucc(store);
        return true;
      } else {
        _logger.warn(_logTag,
            "netDeleteNote failed: remote: ${responseStream.statusCode}");
        _logger.debug(_logTag, "body: $body");
      }
    } catch (e) {
      _logger.warn(_logTag, "netDeleteNote failed: $e");
      handleNetworkError(store, e);
    }
    return false;
  }
}
