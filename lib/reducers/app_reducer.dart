import '../models/app.dart';
import 'task_reducer.dart';
import 'status_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    status: statusReducer(state.status, action),
    tasks: taskReducer(state.tasks, action),
  );
}
