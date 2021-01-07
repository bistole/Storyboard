import 'dart:async';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:storyboard/channel/command.dart';

const MENU_EVENTS = "/MENU_EVENTS";

const MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO";
const MENU_TIMER = "TIMER";

class MenuChannel {
  MethodChannel _channel;

  Future<void> _notifyMenuEvent(MethodCall call) async {
    switch (call.method) {
      case MENU_IMPORT_PHOTO:
        print('receive menu event: ' + call.method);
        getCommandChannel().importPhoto();
        break;
      case MENU_TIMER:
        print('receive timer: ' + (call.arguments as String));
        break;
    }
  }

  void bindMenuEvents() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    String channelName = info.packageName + MENU_EVENTS;
    _channel = MethodChannel(channelName);
    _channel.setMethodCallHandler(_notifyMenuEvent);
  }
}

MenuChannel _menuChannel;

MenuChannel getMenuChannel() {
  if (_menuChannel == null) {
    _menuChannel = MenuChannel();
  }
  return _menuChannel;
}

void setMenuChannel(MenuChannel mc) {
  _menuChannel = mc;
}
