import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyboard/channel/menu_notifier.dart';
import 'package:storyboard/logger/logger.dart';

const MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO";
const MENU_TIMER = "TIMER";

class MenuChannel {
  String _logTag = (MenuChannel).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  MenuNotifier _notifier;
  listenAction(String menu, VoidCallback cb) {
    _notifier.addListener(menu, cb);
  }

  removeAction(String menu, VoidCallback cb) {
    _notifier.removeListener(menu, cb);
  }

  MethodChannel _channel;
  MenuChannel(MethodChannel channel, {@required logger})
      : this._logger = logger {
    _channel = channel;
    _channel.setMethodCallHandler(notifyMenuEvent);
    _notifier = MenuNotifier(logger: this._logger);
  }

  Future<void> notifyMenuEvent(MethodCall call) async {
    switch (call.method) {
      case MENU_IMPORT_PHOTO:
        _logger.info(_logTag, "notifyMenuEvent: MENU_IMPORT_PHOTO");
        _notifier.notifyListeners(call.method);
        break;
      case MENU_TIMER:
        _logger.info(_logTag, "notifyMenuEvent: MENU_TIMER");
        break;
    }
  }
}
