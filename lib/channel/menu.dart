import 'dart:async';

import 'package:flutter/services.dart';
import 'package:storyboard/channel/command.dart';

const MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO";
const MENU_TIMER = "TIMER";

class MenuChannel {
  // required
  CommandChannel _command;
  setCommandChannel(CommandChannel command) {
    _command = command;
  }

  MethodChannel _channel;
  MenuChannel(MethodChannel channel) {
    _channel = channel;
    _channel.setMethodCallHandler(notifyMenuEvent);
  }

  Future<void> notifyMenuEvent(MethodCall call) async {
    switch (call.method) {
      case MENU_IMPORT_PHOTO:
        _command.importPhoto();
        break;
      case MENU_TIMER:
        break;
    }
  }
}
