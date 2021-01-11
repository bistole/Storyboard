import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/configs/channel_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/storage/storage.dart';

class MockStorage extends Mock implements Storage {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockMethodChannel extends Mock implements MethodChannel {}

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
  test('initAfterAppCreated', () async {
    Factory f = getFactory();
    f.storage = MockStorage();
    f.channelManager = MockChannelManager();

    when(f.storage.getPersistDataPath()).thenReturn('project_home/state.json');

    MethodChannel mcMenu = MockMethodChannel();
    MethodChannel mcCommand = MockMethodChannel();
    when(f.channelManager.createChannel(CHANNEL_MENU_EVENTS))
        .thenAnswer((_) async => mcMenu);
    when(f.channelManager.createChannel(CHANNEL_COMMANDS))
        .thenAnswer((_) async => mcCommand);

    runApp(MockApp());
    await f.initAfterAppCreated();

    verify(f.storage.initDataHome()).called(1);
    verify(f.storage.initPhotoStorage()).called(1);
  });
}
