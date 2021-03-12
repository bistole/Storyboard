import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/server.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

class MockActServer extends Mock implements ActServer {}

void main() {
  Store<AppState> store;

  setUp(() {
    store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        taskRepo: TaskRepo(tasks: {}, lastTS: 0),
        queue: Queue(),
        setting: Setting(),
      ),
    );
  });

  test('importPhoto', () async {
    MethodChannel mc = MockMethodChannel();
    String path = "project_home/image.jpeg";
    List<String> paths = [path];
    when(mc.invokeListMethod(any, any)).thenAnswer((_) async => paths);

    var cc = CommandChannel(mc);
    cc.setStore(store);

    await cc.importPhoto();

    var captured = verify(mc.invokeListMethod(captureAny, captureAny)).captured;
    expect(captured[0] as String, 'CMD:OPEN_DIALOG');
    expect(
      captured[1] as Map<String, String>,
      {
        'title': "Import Photo",
        'types': "jpeg;jpg;gif;png",
      },
    );

    expect(
      store.state.status,
      Status(status: StatusKey.AddingPhoto, param1: path),
    );
  });

  test('takePhoto', () async {
    MethodChannel mc = MockMethodChannel();
    String path = "project_home/image.jpeg";
    when(mc.invokeMethod(any, any)).thenAnswer((_) async => path);

    var cc = CommandChannel(mc);
    cc.setStore(store);

    await cc.takePhoto();

    var captured = verify(mc.invokeMethod(captureAny)).captured;
    expect(captured[0] as String, 'CMD:TAKE_PHOTO');

    expect(store.state.status,
        Status(status: StatusKey.AddingPhoto, param1: path));
  });

  test('takeQRCode', () async {
    ActServer actServer = MockActServer();

    MethodChannel mc = MockMethodChannel();
    String code = encodeServerKey('192.168.3.77', 3000);
    when(mc.invokeMethod(any, any)).thenAnswer((_) async => code);

    var cc = CommandChannel(mc);
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
