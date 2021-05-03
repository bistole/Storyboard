import 'package:flutter/material.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/channel/notifier.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/storage/storage.dart';

class ViewsResource {
  Logger logger;
  Notifier notifier;

  ActServer actServer;
  ActPhotos actPhotos;
  ActNotes actNotes;

  DeviceManager deviceManager;
  Storage storage;
  BackendChannel backend;
  MenuChannel menu;
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

  Rect getRectFromWidget(GlobalKey gKey) {
    final keyContext = gKey.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero);
      final size = box.hasSize ? box.size : Size.zero;
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }
    return Rect.zero;
  }

  bool isWiderLayout(BuildContext context) {
    if (getViewResource().deviceManager.isDesktop()) {
      return MediaQuery.of(context).size.width > 400;
    } else {
      return MediaQuery.of(context).orientation == Orientation.landscape;
    }
  }
}

ViewsResource _vr;

setViewResource(ViewsResource vr) {
  _vr = vr;
}

ViewsResource getViewResource() {
  if (_vr == null) {
    _vr = ViewsResource();
  }
  return _vr;
}
