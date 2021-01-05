import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/channel/config.dart';
import 'package:storyboard/channel/menu_events.dart';
import 'package:storyboard/storage/photo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

Store<AppState> _store;

Store<AppState> getStore() {
  return _store;
}

Future<Store<AppState>> initStore() async {
  await initDataHome();
  await initPhotoStorage();

  final homePath = getDataHome();
  final statePath = path.join(homePath, 'state.json');
  print("state path: $statePath");

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

  _store = store;

  initQueue();
  bindMenuEvents();

  return store;
}
