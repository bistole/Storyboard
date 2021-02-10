import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';

import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/actions/tasks.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/channel_manager.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/net/auth.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/net/tasks.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';

const CHANNEL_BACKENDS = "/BACKENDS";
const CHANNEL_MENU_EVENTS = "/MENU_EVENTS";
const CHANNEL_COMMANDS = '/COMMANDS';

class Factory {
  DeviceManager deviceManager;

  ActServer actServer;
  ActPhotos actPhotos;
  ActTasks actTasks;

  NetAuth netAuth;
  NetPhotos netPhotos;
  NetTasks netTasks;
  NetSSE netSSE;
  NetQueue netQueue;

  ChannelManager channelManager;
  BackendChannel backend;
  MenuChannel menu;
  CommandChannel command;

  Store<AppState> store;
  Storage storage;

  Factory() {
    deviceManager = DeviceManager();
    actServer = ActServer();
    actPhotos = ActPhotos();
    actTasks = ActTasks();

    netAuth = NetAuth();
    netPhotos = NetPhotos();
    netTasks = NetTasks();
    netSSE = NetSSE();
    netQueue = NetQueue(60);

    channelManager = ChannelManager();
    storage = Storage();

    actServer.setNetSSE(netSSE);

    actPhotos.setNetQueue(netQueue);
    actPhotos.setStorage(storage);

    actTasks.setNetQueue(netQueue);

    netAuth.setHttpClient(http.Client());

    netPhotos.setHttpClient(http.Client());
    netPhotos.setActPhotos(actPhotos);
    netPhotos.setStorage(storage);
    netPhotos.registerToQueue(netQueue);

    netTasks.setHttpClient(http.Client());
    netTasks.setActTasks(actTasks);
    netTasks.registerToQueue(netQueue);

    netSSE.setGetHttpClient(() => http.Client());

    netSSE.registerUpdateFunc(notifyTypeTask, actTasks.actFetchTasks);
    netSSE.registerUpdateFunc(notifyTypePhoto, actPhotos.actFetchPhotos);

    getViewResource().deviceManager = deviceManager;
    getViewResource().storage = storage;
    getViewResource().actPhotos = actPhotos;
    getViewResource().actTasks = actTasks;
    getViewResource().actServer = actServer;
  }

  Future<MethodChannel> createChannelByName(String name) =>
      channelManager.createChannel(name);

  void checkServerKeyOnDesktop() {
    backend.getCurrentIp().then((localIp) {
      var newServeKey = encodeServerKey(localIp, 3000);
      if (store.state.setting.serverKey != newServeKey) {
        // only first time when serverKey is updated
        store.onChange
            .any((state) => state.setting.serverKey == newServeKey)
            .then((_) => netSSE.connect(store));

        // backend ip is changed, lets change frontend ip too
        store.dispatch(SettingServerKeyAction(serverKey: newServeKey));
      } else {
        // local ip does not changed, check reachable only
        netSSE.connect(store);
      }
    });
  }

  void checkServerKeyOnMobile() {
    if (store.state.setting.serverKey != null) {
      netSSE.connect(store);
    }
  }

  Future<void> initAfterAppCreated() async {
    // init backend
    MethodChannel mcBackend = await createChannelByName(CHANNEL_BACKENDS);
    backend = BackendChannel(mcBackend);

    // init storage
    storage.setDataHome(await backend.getDataHome());
    await storage.initPhotoStorage();

    // init store & start queue
    store = await initStore(storage);
    netQueue.setStore(store);
    netQueue.start();

    // init command
    MethodChannel mcCommand = await createChannelByName(CHANNEL_COMMANDS);
    command = CommandChannel(mcCommand);
    command.setStore(store);
    command.setActServer(actServer);

    // init menu
    MethodChannel mcMenu = await createChannelByName(CHANNEL_MENU_EVENTS);
    menu = MenuChannel(mcMenu);
    menu.setCommandChannel(command);

    getViewResource().command = command;
    getViewResource().backend = backend;

    if (deviceManager.isDesktop()) {
      checkServerKeyOnDesktop();
    } else {
      checkServerKeyOnMobile();
    }
  }
}

Factory _instance;

Factory getFactory() {
  if (_instance == null) {
    _instance = Factory();
  }
  return _instance;
}
