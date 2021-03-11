import 'dart:io';

import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/storage/storage.dart';

Future<Store<AppState>> initStore(Storage storage, Logger logger) async {
  String _LOG_TAG = 'Store';

  final statePath = storage.getPersistDataPath();
  logger.info(_LOG_TAG, "state path: $statePath");

  final persistor = Persistor<AppState>(
    storage: FileStorage(File(statePath)),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  final initialState = await persistor.load();

  final store = new Store<AppState>(
    appReducer,
    initialState: initialState,
    middleware: [persistor.createMiddleware()],
  );

  return store;
}
