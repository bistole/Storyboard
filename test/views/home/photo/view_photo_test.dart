import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/factory.dart';

import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/home/photo/photo_widget.dart';
import 'package:storyboard/views/photo/photo_page.dart';

import '../../../common.dart';

Type typeof<T>() => T;

class MockNetQueue extends Mock implements NetQueue {}

class MockCommandChannel extends Mock implements CommandChannel {}

class MockMenuChannel extends Mock implements MenuChannel {}

void main() {
  Store<AppState> store;
  MockNetQueue netQueue;
  MockNavigatorObserver naviObserver;

  final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
  final photoJson = {
    'uuid': uuid,
    'filename': 'photo_test.jpg',
    'size': '8939',
    'mime': 'image/jpeg',
    'hasOrigin': 'PhotoStatus.None',
    'hasThumb': 'PhotoStatus.None',
    'deleted': 0,
    'updatedAt': 1606406017,
    'createdAt': 1606406017,
    '_ts': 1606406017000,
  };

  group("update item", () {
    setUp(() {
      setFactoryLogger(MockLogger());
      getFactory().store = store = getMockStore(
        pr: PhotoRepo(
          photos: <String, Photo>{uuid: Photo.fromJson(photoJson)},
          lastTS: 0,
        ),
      );

      naviObserver = MockNavigatorObserver();

      Storage s = Storage();
      s.dataHome = "project_home";
      getViewResource().storage = s;

      netQueue = MockNetQueue();
      getViewResource().actPhotos = ActPhotos();
      getViewResource().actPhotos.setLogger(MockLogger());
      getViewResource().actPhotos.setNetQueue(netQueue);
      getViewResource().actPhotos.setStorage(s);
      getViewResource().command = MockCommandChannel();
      getViewResource().menu = MockMenuChannel();
    });

    testWidgets("update item succ", (WidgetTester tester) async {
      var widget = buildTestableWidget(HomePage(title: 'title'), store,
          navigator: naviObserver);
      await tester.pumpWidget(widget);

      // No thumbnail, show indicator
      expect(find.text('ADD PHOTO'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // download thumbnail is succ
      store.dispatch(ThumbnailPhotoAction(
        uuid: uuid,
        status: PhotoStatus.Ready,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Image), findsOneWidget);
      Image img = find.byType(Image).evaluate().first.widget;
      FileImage imgProvider = img.image;
      expect(
        imgProvider.file.path,
        path.join('project_home', 'thumbnails', uuid),
      );

      // tap photo to show detail
      await tester.tap(find.byType(PhotoWidget));
      var c = verify(naviObserver.didPush(captureAny, any)).captured.last
          as MaterialPageRoute;
      expect(c.settings.name, PhotoPage.routeName);
    });
  });
}
