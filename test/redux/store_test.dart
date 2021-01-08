import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/storage/storage.dart';

class MockStorage extends Mock implements Storage {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  MockStorage storage;
  MockMenuChannel menuChannel;

  setUp(() {
    storage = MockStorage();
    setStorage(storage);
    menuChannel = MockMenuChannel();
    setMenuChannel(menuChannel);
  });

  test('initStore', () async {
    // prepare
    when(storage.getPersistDataPath()).thenReturn("persist/state.json");

    // init
    var store = await initStore();
    expect(store.state.photos, {});
    expect(store.state.tasks, {});
    expect(store.state.queue, Queue());

    verify(storage.initDataHome()).called(1);
    verify(storage.initPhotoStorage()).called(1);

    verify(menuChannel.bindMenuEvents()).called(1);
  });
}
