import 'dart:async';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:storyboard/net/command.dart';

const MENU_EVENTS = "/MENU_EVENTS";

const MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO";
const MENU_TIMER = "TIMER";

MethodChannel _channel;

Future<void> _notifyMenuEvent(MethodCall call) async {
  switch (call.method) {
    case MENU_IMPORT_PHOTO:
      print('receive menu event: ' + call.method);
      importPhoto();
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
