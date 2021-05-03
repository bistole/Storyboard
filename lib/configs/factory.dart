import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';

import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/actions/notes.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/channel/notifier.dart';
import 'package:storyboard/configs/channel_manager.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/logger/log_level.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/auth.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/net/notes.dart';
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
  Logger logger;
  Notifier notifier;

  ActServer actServer;
  ActPhotos actPhotos;
  ActNotes actNotes;

  NetAuth netAuth;
  NetPhotos netPhotos;
  NetNotes netNotes;
  NetSSE netSSE;
  NetQueue netQueue;

  ChannelManager channelManager;
  BackendChannel backend;
  MenuChannel menu;
  CommandChannel command;

  Store<AppState> store;
  Storage storage;

  Factory({@required this.logger}) {
    deviceManager = DeviceManager();
    logger.setLevel(LogLevel.debug());
    notifier = Notifier();
    notifier.setLogger(logger);

    actServer = ActServer();
    actPhotos = ActPhotos();
    actNotes = ActNotes();

    netAuth = NetAuth();
    netPhotos = NetPhotos();
    netNotes = NetNotes();
    netSSE = NetSSE();
    netQueue = NetQueue(60);

    channelManager = ChannelManager();
    storage = Storage();

    actServer.setLogger(logger);
    actServer.setNetSSE(netSSE);

    actPhotos.setLogger(logger);
    actPhotos.setNetQueue(netQueue);
    actPhotos.setStorage(storage);

    actNotes.setLogger(logger);
    actNotes.setNetQueue(netQueue);

    netQueue.setLogger(logger);

    netAuth.setLogger(logger);
    netAuth.setHttpClient(http.Client());

    netPhotos.setLogger(logger);
    netPhotos.setHttpClient(http.Client());
    netPhotos.setActPhotos(actPhotos);
    netPhotos.setStorage(storage);
    netPhotos.registerToQueue(netQueue);

    netNotes.setLogger(logger);
    netNotes.setHttpClient(http.Client());
    netNotes.setActNotes(actNotes);
    netNotes.registerToQueue(netQueue);

    netSSE.setLogger(logger);
    netSSE.setGetHttpClient(() => http.Client());
    netSSE.registerUpdateFunc(notifyTypeNote, actNotes.actFetchNotes);
    netSSE.registerUpdateFunc(notifyTypePhoto, actPhotos.actFetchPhotos);

    channelManager.setLogger(logger);
    storage.setLogger(logger);

    getViewResource().deviceManager = deviceManager;
    getViewResource().storage = storage;
    getViewResource().actPhotos = actPhotos;
    getViewResource().actNotes = actNotes;
    getViewResource().actServer = actServer;
    getViewResource().logger = logger;
    getViewResource().notifier = notifier;
  }

  Future<void> initCrashlytics() async {
    await Firebase.initializeApp();

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };
  }

  Future<MethodChannel> createChannelByName(String name) =>
      channelManager.createChannel(name);

  void checkServerKeyOnDesktop() {
    backend.getCurrentIp().then((localIp) {
      var newServeKey = encodeServerKey(localIp, 3000);
      if (newServeKey == null) return;
      if (store.state.setting.serverKey != newServeKey) {
        // only first time when serverKey is updated
        store.onChange
            .any((state) => state.setting.serverKey == newServeKey)
            .then((_) => netSSE.reconnect(store));

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

  Future<void> initMethodChannels() async {
    // init logger
    Directory logDir = await getApplicationDocumentsDirectory();
    logger.setDir(logDir);
    logger.setLevel(LogLevel.warn());

    // init backend
    MethodChannel mcBackend = await createChannelByName(CHANNEL_BACKENDS);
    backend = BackendChannel(mcBackend);
    backend.setLogger(logger);

    // init command
    MethodChannel mcCommand = await createChannelByName(CHANNEL_COMMANDS);
    command = CommandChannel(mcCommand);
    command.setLogger(logger);
    command.setActServer(actServer);

    // init menu
    MethodChannel mcMenu = await createChannelByName(CHANNEL_MENU_EVENTS);
    menu = MenuChannel(mcMenu);
    menu.setLogger(logger);
    menu.setNotifier(notifier);

    // set to view resource
    getViewResource().command = command;
    getViewResource().backend = backend;
    getViewResource().menu = menu;
  }

  Future<void> initStoreAndStorage() async {
    // init storage
    storage.setDataHome(await backend.getDataHome());
    await storage.initPhotoStorage();

    // init store & start queue
    store = await initStore(storage, logger);

    netQueue.setStore(store);
    netQueue.start();

    command.setStore(store);
  }

  Future<void> checkServerStatus() async {
    if (deviceManager.isDesktop()) {
      checkServerKeyOnDesktop();
    } else {
      checkServerKeyOnMobile();
    }
  }
}

Factory _instance;
Logger _logger;

setFactoryLogger(Logger logger) {
  _logger = logger;
}

setFactory(Factory fact) {
  _instance = fact;
}

Factory getFactory() {
  if (_instance == null) {
    _instance = Factory(logger: _logger == null ? Logger() : _logger);
  }
  return _instance;
}
