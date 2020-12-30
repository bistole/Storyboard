import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/menu_events.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/net/tasks.dart';
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

  bindMenuEvents();

  // Use timer to trigger fetchTasks/fetchPhotos after launch
  Future.delayed(Duration(seconds: 30), () async {
    await fetchTasks(store);
    await fetchPhotos(store);
  });

  _store = store;
  return store;
}
