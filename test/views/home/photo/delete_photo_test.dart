import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/home/photo/photo_widget.dart';

import '../../../common.dart';

Type typeof<T>() => T;

class MockNetQueue extends Mock implements NetQueue {}

class MockCommandChannel extends Mock implements CommandChannel {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  Store<AppState> store;
  MockNetQueue netQueue;

  final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
  final photoJson = {
    'uuid': uuid,
    'filename': 'photo_test.jpg',
    'size': '8939',
    'mime': 'image/jpeg',
    'hasOrigin': 'PhotoStatus.Ready',
    'hasThumb': 'PhotoStatus.Ready',
    'deleted': 0,
    'updatedAt': 1606406017,
    'createdAt': 1606406017,
    '_ts': 1606406017000,
  };

  group("delete item", () {
    setUp(() {
      setFactoryLogger(MockLogger());
      getFactory().store = store = getMockStore(
        pr: PhotoRepo(
          photos: <String, Photo>{uuid: Photo.fromJson(photoJson)},
          lastTS: 0,
        ),
      );

      Storage s = Storage();
      s.dataHome = "project_home";

      netQueue = MockNetQueue();
      getViewResource().storage = s;
      getViewResource().actPhotos = ActPhotos();
      getViewResource().actPhotos.setLogger(MockLogger());
      getViewResource().actPhotos.setNetQueue(netQueue);
      getViewResource().actPhotos.setStorage(s);
      getViewResource().command = MockCommandChannel();
      getViewResource().menu = MockMenuChannel();
    });

    testWidgets("delete item succ", (WidgetTester tester) async {
      var widget = buildTestableWidget(HomePage(title: 'title'), store);
      await tester.pumpWidget(widget);

      expect(find.text('ADD PHOTO'), findsOneWidget);

      // find delete icon
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // hover
      final gesture = await tester.createGesture();
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(PhotoWidget)));
      await tester.pumpAndSettle();

      // tap to delete
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.byType(PhotoWidget), findsNothing);
    });
  });
}
