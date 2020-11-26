import '../models/app.dart';
import 'task_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    tasks: taskReducer(state.tasks, action),
  );
}
