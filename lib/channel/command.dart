import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';

const CMD_OPEN_DIALOG = 'CMD:OPEN_DIALOG';
const CMD_TAKE_PHOTO = 'CMD:TAKE_PHOTO';
const CMD_TAKE_QRCODE = "CMD:TAKE_QRCODE";

class CommandChannel {
  // required
  Store<AppState> _store;
  setStore(Store<AppState> store) {
    _store = store;
  }

  // required
  MethodChannel _channel;
  CommandChannel(MethodChannel channel) {
    _channel = channel;
  }

  Future<List<String>> _openFileDialog(String title, String types) async {
    final Map<String, String> params = {"title": title, "types": types};
    final List<String> answer =
        await _channel.invokeListMethod<String>(CMD_OPEN_DIALOG, params);
    return answer;
  }

  Future<void> importPhoto() async {
    List<String> paths = await _openFileDialog(
      "Import Photo",
      "jpeg;jpg;gif;png",
    );

    if (paths.length > 0) {
      _store.dispatch(
        ChangeStatusWithPathAction(
          status: StatusKey.AddingPhoto,
          path: paths[0],
        ),
      );
    }
  }

  Future<void> takePhoto() async {
    String path = await _channel.invokeMethod<String>(CMD_TAKE_PHOTO);
    if (path != null) {
      _store.dispatch(
        ChangeStatusWithPathAction(
          status: StatusKey.AddingPhoto,
          path: path,
        ),
      );
    }
  }

  Future<void> takeQRCode() async {
    String code = await _channel.invokeMethod<String>(CMD_TAKE_QRCODE);
    if (code != null) {
      _store.dispatch(SettingServerKeyAction(serverKey: code));
    }
  }
}
