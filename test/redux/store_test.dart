import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/storage/storage.dart';

class MockStorage extends Mock implements Storage {}

class MockLogger extends Mock implements Logger {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  setUp(() {});

  test('initStore', () async {
    // prepare
    Storage s = MockStorage();
    when(s.getPersistDataPath()).thenReturn("persist/state.json");

    Logger l = MockLogger();

    // init
    var store = await initStore(s, l);
    expect(store.state.photoRepo.photos, {});
    expect(store.state.taskRepo.tasks, {});
    expect(store.state.queue, Queue());
  });
}
