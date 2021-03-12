import 'dart:async';

import 'package:flutter/services.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/logger/logger.dart';

const MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO";
const MENU_TIMER = "TIMER";

class MenuChannel {
  String _LOG_TAG = (MenuChannel).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

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
        _logger.info(_LOG_TAG, "notifyMenuEvent: MENU_IMPORT_PHOTO");
        _command.importPhoto();
        break;
      case MENU_TIMER:
        _logger.info(_LOG_TAG, "notifyMenuEvent: MENU_TIMER");
        break;
    }
  }
}
