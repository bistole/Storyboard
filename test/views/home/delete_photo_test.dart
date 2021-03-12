import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/channel/command.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/queue.dart';
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
import 'package:storyboard/views/home/photo_widget.dart';

Type typeof<T>() => T;

class MockNetQueue extends Mock implements NetQueue {}

class MockCommandChannel extends Mock implements CommandChannel {}

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

  Widget buildTestableWidget(Widget widget) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        home: widget,
      ),
    );
  }

  group("delete item", () {
    setUp(() {
      getFactory().store = store = Store<AppState>(
        appReducer,
        initialState: AppState(
          status: Status.noParam(StatusKey.ListTask),
          photoRepo: PhotoRepo(
            photos: <String, Photo>{uuid: Photo.fromJson(photoJson)},
            lastTS: 0,
          ),
          taskRepo: TaskRepo(tasks: {}, lastTS: 0),
          setting: Setting(
            clientID: 'client-id',
            serverKey: 'server-key',
            serverReachable: Reachable.Unknown,
          ),
        ),
      );

      Storage s = Storage();
      s.dataHome = "project_home";

      netQueue = MockNetQueue();
      getViewResource().storage = s;
      getViewResource().actPhotos = ActPhotos();
      getViewResource().actPhotos.setNetQueue(netQueue);
      getViewResource().actPhotos.setStorage(s);
      getViewResource().command = MockCommandChannel();
    });

    testWidgets("delete item succ", (WidgetTester tester) async {
      var widget = buildTestableWidget(HomePage(title: 'title'));
      await tester.pumpWidget(widget);

      expect(find.text('ADD PHOTO'), findsOneWidget);

      // find popmenu button
      expect(find.byType(PhotoWidget), findsOneWidget);
      var popbtnFinder = find.descendant(
        of: find.byType(PhotoWidget).first,
        matching: find.byType(typeof<PopupMenuButton<String>>()),
      );
      expect(popbtnFinder, findsOneWidget);

      // tap the button
      await tester.tap(popbtnFinder);
      await tester.pumpAndSettle();

      // find two buttons
      var itmFinder = find.byType(typeof<PopupMenuItem<String>>());
      expect(itmFinder, findsNWidgets(2));

      // tap delete
      var deleteItmElem = tester.element(itmFinder.first);
      expect(
        (deleteItmElem.widget as PopupMenuItem<String>).value,
        "delete",
      );
      await tester.tap(itmFinder.first);
      await tester.pumpAndSettle();

      expect(find.byType(PhotoWidget), findsNothing);
    });
  });
}
