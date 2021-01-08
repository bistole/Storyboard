import 'dart:io';

import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/net/tasks.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

Store<AppState> _store;

Store<AppState> getStore() {
  return _store;
}

setStore(Store<AppState> s) {
  _store = s;
}

Future<Store<AppState>> initStore() async {
  Storage s = getStorage();
  await s.initDataHome();
  await s.initPhotoStorage();

  final statePath = s.getPersistDataPath();
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

  var netQueue = getNetQueue();
  getNetPhotos().registerToQueue(netQueue);
  getNetTasks().registerToQueue(netQueue);
  netQueue.registerPeriodicTrigger(getActTasks().actFetchTasks);
  netQueue.registerPeriodicTrigger(getActPhotos().actFetchPhotos);

  getMenuChannel().bindMenuEvents();

  return store;
}
