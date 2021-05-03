import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/reducers/photo_reducer.dart';
import 'package:storyboard/redux/reducers/queue_reducer.dart';
import 'package:storyboard/redux/reducers/setting_reducer.dart';

import 'note_reducer.dart';
import 'status_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    status: statusReducer(state.status, action),
    noteRepo: noteReducer(state.noteRepo, action),
    photoRepo: photoReducer(state.photoRepo, action),
    queue: queueReducer(state.queue, action),
    setting: settingReducer(state.setting, action),
  );
}
