import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/storage/storage.dart';

class ViewsResource {
  ActPhotos actPhotos;
  ActTasks actTasks;
  Storage storage;
  CommandChannel command;
}

ViewsResource _vr;

ViewsResource getViewResource() {
  if (_vr == null) {
    _vr = ViewsResource();
  }
  return _vr;
}
