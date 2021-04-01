import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/channel_manager.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';

import '../common.dart';
import '../redux/store_test.dart';

class MockStorage extends Mock implements Storage {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockCommandChannel extends Mock implements CommandChannel {}

class MockBackendChannel extends Mock implements BackendChannel {}

class MockDeviceManager extends Mock implements DeviceManager {}

class MockNetSSE extends Mock implements NetSSE {}

class MockPathProviderPlatform
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String> getApplicationSupportPath() async {
    throw UnimplementedError();
  }

  @override
  Future<String> getApplicationDocumentsPath() {
    return Future.value(".");
  }

  @override
  Future<String> getDownloadsPath() {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getExternalCachePaths() {
    throw UnimplementedError();
  }

  @override
  Future<String> getExternalStoragePath() {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getExternalStoragePaths({StorageDirectory type}) {
    throw UnimplementedError();
  }

  @override
  Future<String> getLibraryPath() {
    throw UnimplementedError();
  }

  @override
  Future<String> getTemporaryPath() {
    throw UnimplementedError();
  }
}

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
  setUp(() {
    setFactoryLogger(MockLogger());
  });

  buildStore(String serverKey) {
    return getMockStore(setting: Setting(serverKey: serverKey));
  }

  test('initMethodChannels', () async {
    PathProviderPlatform.instance = MockPathProviderPlatform();

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
      when(f.netSSE.reconnect(any)).thenAnswer((_) {
        connectCalled = true;
        return null;
      });

      f.checkServerStatus();

      while (!connectCalled) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      var capture = verify(f.netSSE.reconnect(captureAny)).captured;
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
