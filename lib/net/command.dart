import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

const COMMANDS = '/COMMANDS';

const CMD_OPEN_DIALOG = 'CMD:OPEN_DIALOG';

MethodChannel _methodCommand;

Future<MethodChannel> _getCommandsChannel() async {
  if (_methodCommand == null) {
    PackageInfo info = await PackageInfo.fromPlatform();
    String channelName = info.packageName + COMMANDS;
    _methodCommand = MethodChannel(channelName);
  }
  return _methodCommand;
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
  // TODO: upload images
  paths.forEach((path) {
    print(path);
  });
}
