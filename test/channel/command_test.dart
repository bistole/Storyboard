import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';

import '../common.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

class MockActServer extends Mock implements ActServer {}

void main() {
  Store<AppState> store;

  setUp(() {
    setFactoryLogger(MockLogger());
    store = getMockStore(status: Status.noParam(StatusKey.ListNote));
  });

  test('importPhoto', () async {
    MethodChannel mc = MockMethodChannel();

    String path = "project_home/image.jpeg";
    List<String> paths = [path];
    when(mc.invokeListMethod(any, any)).thenAnswer((_) async => paths);

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    String newPath = await cc.importPhoto();

    var captured = verify(mc.invokeListMethod(captureAny, captureAny)).captured;
    expect(captured[0] as String, 'CMD:OPEN_DIALOG');
    expect(
      captured[1] as Map<String, String>,
      {
        'title': "Import Photo",
        'types': "jpeg;jpg;gif;png",
      },
    );

    expect(newPath, path);
  });

  test('takePhoto', () async {
    MethodChannel mc = MockMethodChannel();
    String path = "project_home/image.jpeg";
    when(mc.invokeMethod(any, any)).thenAnswer((_) async => path);

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    String getPath = await cc.takePhoto();

    var captured = verify(mc.invokeMethod(captureAny)).captured;
    expect(captured[0] as String, 'CMD:TAKE_PHOTO');

    expect(getPath, path);
  });

  test('takeQRCode', () async {
    ActServer actServer = MockActServer();

    MethodChannel mc = MockMethodChannel();
    String code = encodeServerKey('192.168.3.77', 3000);
    when(mc.invokeMethod(any, any)).thenAnswer((_) async => code);

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);
    cc.setActServer(actServer);

    await cc.takeQRCode();

    var captured = verify(mc.invokeMethod(captureAny)).captured;
    expect(captured[0] as String, 'CMD:TAKE_QRCODE');

    var capture =
        verify(actServer.actChangeServerKey(captureAny, captureAny)).captured;
    expect(capture[0], store);
    expect(capture[1], code);
  });
}
