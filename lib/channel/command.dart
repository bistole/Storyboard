import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/channel/notifier.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';

const CMD_READY = "CMD:READY";
const CMD_OPEN_DIALOG = 'CMD:OPEN_DIALOG';
const CMD_TAKE_PHOTO = 'CMD:TAKE_PHOTO';
const CMD_IMPORT_PHOTO = 'CMD:IMPORT_PHOTO';
const CMD_SHARE_OUT_PHOTO = 'CMD:SHARE_OUT_PHOTO';
const CMD_SHARE_OUT_TEXT = 'CMD:SHARE_OUT_TEXT';
const CMD_TAKE_QRCODE = "CMD:TAKE_QRCODE";

const CMD_SHARE_IN_PHOTO = 'CMD:SHARE_IN_PHOTO';
const CMD_SHARE_IN_TEXT = 'CMD:SHARE_IN_TEXT';

const NOTIFIER_COMMAND_PREFIX = 'COMMAND|';

class CommandChannel {
  String _logTag = (CommandChannel).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  Notifier _notifier;
  void setNotifier(Notifier notifier) {
    _notifier = notifier;
    _notifier.registerNotifier(NOTIFIER_COMMAND_PREFIX + CMD_SHARE_IN_PHOTO);
    _notifier.registerNotifier(NOTIFIER_COMMAND_PREFIX + CMD_SHARE_IN_TEXT);
  }

  listenAction(String cmd, VoidCallback cb) {
    _notifier.addListener(NOTIFIER_COMMAND_PREFIX + cmd, cb);
  }

  removeAction(String cmd, VoidCallback cb) {
    _notifier.removeListener(NOTIFIER_COMMAND_PREFIX + cmd, cb);
  }

  clearActionValue(String cmd) {
    _notifier.clearValue(NOTIFIER_COMMAND_PREFIX + cmd);
  }

  T getActionValue<T>(String cmd) {
    return _notifier.getValue<T>(NOTIFIER_COMMAND_PREFIX + cmd);
  }

  // required
  Store<AppState> _store;
  setStore(Store<AppState> store) {
    _store = store;
  }

  ActServer _actServer;
  setActServer(ActServer actServer) {
    _actServer = actServer;
  }

  // required
  MethodChannel _channel;
  CommandChannel(MethodChannel channel) {
    _channel = channel;
    _channel.setMethodCallHandler(notifyCommandEvent);
  }

  Future<void> notifyCommandEvent(MethodCall call) async {
    switch (call.method) {
      case CMD_SHARE_IN_PHOTO:
        _logger.info(_logTag, "notifyCommandEvent: CMD_SHARE_IN_PHOTO");
        var url = call.arguments as String;
        _notifier.notifyListeners<String>(
            NOTIFIER_COMMAND_PREFIX + CMD_SHARE_IN_PHOTO,
            param: url);
        break;
      case CMD_SHARE_IN_TEXT:
        _logger.info(_logTag, "notifyCommandEvent: CMD_SHARE_IN_TEXT");
        var text = call.arguments as String;
        _notifier.notifyListeners<String>(
            NOTIFIER_COMMAND_PREFIX + CMD_SHARE_IN_TEXT,
            param: text);
        break;
    }
  }

  Future<void> setChannelReady() async {
    _channel.invokeMethod(CMD_READY);
  }

  Future<List<String>> _openFileDialog(String title, String types) async {
    final Map<String, String> params = {"title": title, "types": types};
    final List<String> answer =
        await _channel.invokeListMethod<String>(CMD_OPEN_DIALOG, params);
    return answer;
  }

  Future<String> importPhotoFromDisk() async {
    _logger.info(_logTag, "importPhotoFromDisk");
    List<String> paths = await _openFileDialog(
      "Import Photo",
      "jpeg;jpg;gif;png",
    );

    if (paths.length > 0) {
      _logger.info(_logTag, "importPhotoFromDisk succ");
      return paths[0];
    } else {
      _logger.info(_logTag, "importPhotoFromDisk cancel");
      return null;
    }
  }

  Future<String> takePhoto() async {
    _logger.info(_logTag, "takePhoto");
    String path = await _channel.invokeMethod<String>(CMD_TAKE_PHOTO);
    if (path != null) {
      _logger.info(_logTag, "takePhoto succ");
      return path;
    } else {
      _logger.info(_logTag, "takePhoto cancel");
      return null;
    }
  }

  Future<String> importPhotoFromAlbum() async {
    _logger.info(_logTag, "importPhotoFromAlbum");
    String path = await _channel.invokeMethod<String>(CMD_IMPORT_PHOTO);
    if (path != null) {
      _logger.info(_logTag, "importPhotoFromAlbum succ");
      return path;
    } else {
      _logger.info(_logTag, "importPhotoFromAlbum cancel");
      return null;
    }
  }

  Future<String> importPhoto() async {
    _logger.info(_logTag, "importPhoto");
    String path = await _channel.invokeMethod<String>(CMD_IMPORT_PHOTO);
    if (path != null) {
      _logger.info(_logTag, "importPhoto succ");
      return path;
    } else {
      _logger.info(_logTag, "importPhoto cancel");
      return null;
    }
  }

  Future<void> sharePhoto(String name, String mime, String path) async {
    _logger.info(_logTag, "sharePhoto");
    await _channel.invokeMethod<bool>(CMD_SHARE_OUT_PHOTO, [name, mime, path]);
  }

  Future<void> shareText(String text) async {
    _logger.info(_logTag, "shareText");
    await _channel.invokeMethod<String>(CMD_SHARE_OUT_TEXT, text);
  }

  Future<void> takeQRCode() async {
    _logger.info(_logTag, "takeQRCode");
    String code = await _channel.invokeMethod<String>(CMD_TAKE_QRCODE);
    if (code != null) {
      if (decodeServerKey(code) == null) {
        _logger.warn(_logTag, "takeQRCode invalid");
        throw new Exception("invalid");
      }
      _logger.info(_logTag, "takeQRCode succ");
      _logger.debug(_logTag, "takeQRCode code = $code");
      _actServer.actChangeServerKey(_store, code);
      return true;
    }
    _logger.info(_logTag, "takeQRCode cancel");
    return false;
  }
}
