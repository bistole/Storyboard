import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/store.dart';

const COMMANDS = '/COMMANDS';

const CMD_OPEN_DIALOG = 'CMD:OPEN_DIALOG';

class CommandChannel {
  MethodChannel _channel;

  Future<MethodChannel> _getCommandsChannel() async {
    if (_channel == null) {
      PackageInfo info = await PackageInfo.fromPlatform();
      String channelName = info.packageName + COMMANDS;
      _channel = MethodChannel(channelName);
    }
    return _channel;
  }

  Future<List<String>> _openFileDialog(String title, String types) async {
    final MethodChannel methodCommand = await _getCommandsChannel();
    final Map<String, String> params = {"title": title, "types": types};
    final List<String> answer =
        await methodCommand.invokeListMethod<String>(CMD_OPEN_DIALOG, params);
    return answer;
  }

  Future<void> importPhoto() async {
    List<String> paths =
        await _openFileDialog("Import Photo", "jpeg;jpg;gif;png");

    if (paths.length > 0) {
      getStore().dispatch(ChangeStatusWithPathAction(
        status: StatusKey.AddingPhoto,
        path: paths[0],
      ));
    }
  }
}

CommandChannel _commandChannel;

CommandChannel getCommandChannel() {
  if (_commandChannel == null) {
    _commandChannel = CommandChannel();
  }
  return _commandChannel;
}

void setCommandChannel(CommandChannel cc) {
  _commandChannel = cc;
}

