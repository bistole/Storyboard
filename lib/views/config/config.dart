import 'package:flutter/material.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/storage/storage.dart';

class ViewsResource {
  Logger logger;

  ActServer actServer;
  ActPhotos actPhotos;
  ActTasks actTasks;

  DeviceManager deviceManager;
  Storage storage;
  BackendChannel backend;
  CommandChannel command;

  Map<String, GlobalKey> keyPool = {};
  GlobalKey getGlobalKeyByName(String name) {
    if (keyPool[name] == null) {
      keyPool[name] = GlobalKey();
    }
    return keyPool[name];
  }

  Size getSizeFromWidget(GlobalKey gKey) {
    final keyContext = gKey.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      final size = box.hasSize ? box.size : Size.zero;
      return size;
    }
    return Size.zero;
  }
}

ViewsResource _vr;

ViewsResource getViewResource() {
  if (_vr == null) {
    _vr = ViewsResource();
  }
  return _vr;
}
