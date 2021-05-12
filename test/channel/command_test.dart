import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/notifier.dart';
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

  test('setReady', () async {
    MethodChannel mc = MockMethodChannel();

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    cc.setChannelReady();
    var captured = verify(mc.invokeMethod(captureAny)).captured;
    expect(captured[0] as String, 'CMD:READY');
  });

  test('importPhotoFromDisk', () async {
    MethodChannel mc = MockMethodChannel();

    String path = "project_home/image.jpeg";
    List<String> paths = [path];
    when(mc.invokeListMethod(any, any)).thenAnswer((_) async => paths);

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    String newPath = await cc.importPhotoFromDisk();

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

  test('importPhotoFromAlbum', () async {
    MethodChannel mc = MockMethodChannel();
    String path = "project_home/image.jpeg";
    when(mc.invokeMethod(any, any)).thenAnswer((_) async => path);

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    String getPath = await cc.importPhotoFromAlbum();

    var captured = verify(mc.invokeMethod(captureAny)).captured;
    expect(captured[0] as String, 'CMD:IMPORT_PHOTO');

    expect(getPath, path);
  });

  test('sharePhoto', () {
    MethodChannel mc = MockMethodChannel();

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    var path = 'this/path/to/share.jpg';
    cc.sharePhoto(path);

    var captured = verify(mc.invokeMethod(captureAny, captureAny)).captured;
    expect(captured[0] as String, 'CMD:SHARE_OUT_PHOTO');
    expect(captured[1] as String, path);
  });

  test('shareText', () {
    MethodChannel mc = MockMethodChannel();

    var cc = CommandChannel(mc);
    cc.setLogger(MockLogger());
    cc.setStore(store);

    var text = 'here is the text';
    cc.shareText(text);

    var captured = verify(mc.invokeMethod(captureAny, captureAny)).captured;
    expect(captured[0] as String, 'CMD:SHARE_OUT_TEXT');
    expect(captured[1] as String, text);
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

  test('notifier', () async {
    var called = 0;
    var func = () {
      called++;
    };

    MethodChannel mc = MockMethodChannel();

    Notifier nf = Notifier();
    nf.setLogger(MockLogger());

    CommandChannel commandC = CommandChannel(mc);
    commandC.setNotifier(nf);
    commandC.setLogger(MockLogger());
    commandC.listenAction(CMD_SHARE_IN_PHOTO, func);
    commandC.listenAction(CMD_SHARE_IN_TEXT, func);

    var captured = verify(mc.setMethodCallHandler(captureAny)).captured.single;
    expect(captured, commandC.notifyCommandEvent);

    // share in photo
    commandC.notifyCommandEvent(MethodCall('CMD:SHARE_IN_PHOTO', 'photo_uri'));
    var ret1 = await Future.delayed(Duration(milliseconds: 300), () => called);
    expect(ret1, 1);

    expect(commandC.getActionValue(CMD_SHARE_IN_PHOTO), 'photo_uri');
    commandC.clearActionValue(CMD_SHARE_IN_PHOTO);
    expect(commandC.getActionValue(CMD_SHARE_IN_PHOTO), null);

    commandC.removeAction(CMD_SHARE_IN_PHOTO, func);
    commandC.notifyCommandEvent(MethodCall('CMD:SHARE_IN_PHOTO'));
    var ret2 = await Future.delayed(Duration(milliseconds: 300), () => called);
    expect(ret2, 1);

    // share in text
    commandC.notifyCommandEvent(MethodCall('CMD:SHARE_IN_TEXT', 'text'));
    var ret3 = await Future.delayed(Duration(milliseconds: 300), () => called);
    expect(ret3, 2);

    expect(commandC.getActionValue(CMD_SHARE_IN_TEXT), 'text');
    commandC.clearActionValue(CMD_SHARE_IN_TEXT);
    expect(commandC.getActionValue(CMD_SHARE_IN_TEXT), null);

    commandC.removeAction(CMD_SHARE_IN_TEXT, func);
    commandC.notifyCommandEvent(MethodCall('CMD:SHARE_IN_TEXT'));
    var ret4 = await Future.delayed(Duration(milliseconds: 300), () => called);
    expect(ret4, 2);
  });
}
