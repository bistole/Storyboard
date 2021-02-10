import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/menu.dart';
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
    expect(store.state.photoRepo.photos, {});
    expect(store.state.taskRepo.tasks, {});
    expect(store.state.queue, Queue());
  });
}
