import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/storage/storage.dart';

class MockStorage extends Mock implements Storage {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  setUp(() {});

  test('initStore', () async {
    // prepare
    Storage s = MockStorage();
    when(s.getPersistDataPath()).thenReturn("persist/state.json");

    // init
    var store = await initStore(s);
    expect(store.state.photos, {});
    expect(store.state.tasks, {});
    expect(store.state.queue, Queue());

    // Factory f = getFactory();
    // verify(f.storage.initDataHome()).called(1);
    // verify(f.storage.initPhotoStorage()).called(1);

    // verify(menuChannel.bindMenuEvents()).called(1);
  });
}
