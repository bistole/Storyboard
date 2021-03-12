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
}

ViewsResource _vr;

ViewsResource getViewResource() {
  if (_vr == null) {
    _vr = ViewsResource();
  }
  return _vr;
}
