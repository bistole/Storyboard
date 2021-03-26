import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_view/photo_view.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/logger/logger.dart';

import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/home/photo/photo_widget.dart';
import 'package:storyboard/views/photo/page.dart';

Type typeof<T>() => T;

class MockLogger extends Mock implements Logger {}

class MockNetQueue extends Mock implements NetQueue {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockCommandChannel extends Mock implements CommandChannel {}

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

  Widget buildTestableWidget(Widget widget) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        home: widget,
        navigatorObservers: [naviObserver],
        routes: {
          PhotoPage.routeName: (_) => PhotoPage(),
        },
      ),
    );
  }

  group("update item", () {
    setUp(() {
      getFactory().store = store = Store<AppState>(
        appReducer,
        initialState: AppState(
          status: Status.noParam(StatusKey.ListPhoto),
          taskRepo: TaskRepo(tasks: {}, lastTS: 0),
          photoRepo: PhotoRepo(
            photos: <String, Photo>{uuid: Photo.fromJson(photoJson)},
            lastTS: 0,
          ),
          setting: Setting(
            clientID: 'client-id',
            serverKey: 'server-key',
            serverReachable: Reachable.Unknown,
          ),
        ),
      );

      naviObserver = MockNavigatorObserver();

      Storage s = Storage();
      s.dataHome = "project_home";
      getViewResource().storage = s;

      netQueue = MockNetQueue();
      getViewResource().logger = MockLogger();
      getViewResource().actPhotos = ActPhotos();
      getViewResource().actPhotos.setLogger(MockLogger());
      getViewResource().actPhotos.setNetQueue(netQueue);
      getViewResource().actPhotos.setStorage(s);
      getViewResource().command = MockCommandChannel();
    });

    testWidgets("update item succ", (WidgetTester tester) async {
      var widget = buildTestableWidget(HomePage(title: 'title'));
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
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // show detail but origin is not downloaded
      expect(find.text('RESET'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(PhotoPage).first,
            matching: find.byType(PhotoView),
          ),
          findsNothing);

      // download origin is succ
      getFactory().store.dispatch(DownloadPhotoAction(
            uuid: uuid,
            status: PhotoStatus.Ready,
          ));
      await tester.pumpAndSettle();

      expect(
          find.descendant(
            of: find.byType(PhotoPage).first,
            matching: find.byType(PhotoView),
          ),
          findsOneWidget);
      PhotoView imgDetail = find
          .descendant(
            of: find.byType(PhotoPage).first,
            matching: find.byType(PhotoView),
          )
          .evaluate()
          .first
          .widget;

      FileImage imgDetailProvider = imgDetail.imageProvider;
      expect(
        imgDetailProvider.file.path,
        path.join('project_home', 'photos', uuid),
      );
    });
  });
}
