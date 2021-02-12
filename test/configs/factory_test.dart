import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/configs/channel_manager.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';

import '../channel/menu_test.dart';
import '../redux/store_test.dart';

class MockStorage extends Mock implements Storage {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockBackendChannel extends Mock implements BackendChannel {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockNetSSE extends Mock implements NetSSE {}

class MockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Text("hello, world"),
    );
  }
}

void main() {
  buildStore(String serverKey) {
    return Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        taskRepo: TaskRepo(tasks: {}, lastTS: 0),
        queue: Queue(),
        setting: Setting(serverKey: serverKey),
      ),
    );
  }

  test('initMethodChannels', () async {
    Factory f = getFactory();
    f.channelManager = MockChannelManager();

    MethodChannel mcMenu = MockMethodChannel();
    MethodChannel mcCommand = MockMethodChannel();
    MethodChannel mcBackend = MockMethodChannel();
    when(f.channelManager.createChannel(CHANNEL_MENU_EVENTS))
        .thenAnswer((_) async => mcMenu);
    when(f.channelManager.createChannel(CHANNEL_BACKENDS))
        .thenAnswer((_) async => mcBackend);
    when(f.channelManager.createChannel(CHANNEL_COMMANDS))
        .thenAnswer((_) async => mcCommand);

    await f.initMethodChannels();
    expect(f.menu, isNotNull);
    expect(f.backend, isNotNull);
    expect(f.command, isNotNull);
    expect(getViewResource().command, f.command);
    expect(getViewResource().backend, f.backend);
  });

  test('initStoreAndStorage', () async {
    Factory f = getFactory();
    f.storage = MockStorage();
    f.menu = MockMenuChannel();
    f.command = MockCommandChannel();
    f.backend = MockBackendChannel();

    const datahome = '/Users/storyboard/Library/com.laterhorse.storyboard/';

    when(f.storage.getPersistDataPath()).thenReturn('project_home/state.json');
    when(f.backend.getDataHome()).thenAnswer((_) async => datahome);

    runApp(MockApp());
    await f.initStoreAndStorage();

    var capture = verify(f.storage.setDataHome(captureAny)).captured;
    expect(capture[0] as String, datahome);
    verify(f.storage.initPhotoStorage()).called(1);
  });

  group('checkServerStatus', () {
    test('desktop - ip same', () async {
      var oldIP = "192.168.3.135";
      var oldServerKey = encodeServerKey(oldIP, 3000);

      Factory f = getFactory();
      f.store = buildStore(oldServerKey);
      f.deviceManager = MockDeviceManager();
      f.backend = MockBackendChannel();
      f.netSSE = MockNetSSE();

      var connectCalled = false;

      when(f.deviceManager.isDesktop()).thenReturn(true);
      when(f.backend.getCurrentIp()).thenAnswer((_) async => oldIP);
      when(f.netSSE.connect(any)).thenAnswer((_) {
        connectCalled = true;
        return null;
      });

      f.checkServerStatus();

      while (!connectCalled) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      var capture = verify(f.netSSE.connect(captureAny)).captured;
      expect(capture[0], f.store);
    });

    test('desktop - ip changed', () async {
      var oldIP = "192.168.3.135";
      var oldServerKey = encodeServerKey(oldIP, 3000);
      var newIP = "192.168.6.120";
      var newServerKey = encodeServerKey(newIP, 3000);

      Factory f = getFactory();
      f.store = buildStore(oldServerKey);
      f.deviceManager = MockDeviceManager();
      f.backend = MockBackendChannel();
      f.netSSE = MockNetSSE();

      var connectCalled = false;

      when(f.deviceManager.isDesktop()).thenReturn(true);
      when(f.backend.getCurrentIp()).thenAnswer((_) async => newIP);
      when(f.netSSE.connect(any)).thenAnswer((_) {
        connectCalled = true;
        return null;
      });

      f.checkServerStatus();

      while (!connectCalled) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      var capture = verify(f.netSSE.connect(captureAny)).captured;
      expect(capture[0], f.store);

      expect(f.store.state.setting.serverKey, newServerKey);
    });

    test('mobile', () async {
      var oldIP = "192.168.3.135";
      var oldServerKey = encodeServerKey(oldIP, 3000);

      Factory f = getFactory();
      f.store = buildStore(oldServerKey);
      f.deviceManager = MockDeviceManager();
      f.netSSE = MockNetSSE();

      var connectCalled = false;

      when(f.deviceManager.isDesktop()).thenReturn(false);
      when(f.netSSE.connect(any)).thenAnswer((_) {
        connectCalled = true;
        return null;
      });

      f.checkServerStatus();

      while (!connectCalled) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      var capture = verify(f.netSSE.connect(captureAny)).captured;
      expect(capture[0], f.store);
    });
  });
}
