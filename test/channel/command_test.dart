import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  Store<AppState> store;

  setUp(() {
    store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photos: {},
        tasks: {},
        queue: Queue(),
      ),
    );
  });

  test('command', () async {
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
}
