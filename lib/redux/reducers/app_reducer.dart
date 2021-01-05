import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/reducers/photo_reducer.dart';
import 'package:storyboard/redux/reducers/queue_reducer.dart';

import 'task_reducer.dart';
import 'status_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    status: statusReducer(state.status, action),
    tasks: taskReducer(state.tasks, action),
    photos: photoReducer(state.photos, action),
    queue: queueReducer(state.queue, action),
  );
}
