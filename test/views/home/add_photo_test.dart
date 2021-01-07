import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

import 'package:storyboard/channel/command.dart';
import 'package:storyboard/channel/config.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/redux/store.dart';
import 'package:storyboard/views/home/page.dart';

class MockCommandChannel extends Mock implements CommandChannel {}

class MockNetQueue extends Mock implements NetQueue {}

void main() {
  Store<AppState> store;
  MockNetQueue netQueue;

  Widget buildTestableWidget(Widget widget) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  group(
    "add photo",
    () {
      setUp(() {
        store = Store<AppState>(
          appReducer,
          initialState: AppState(
            status: Status.noParam(StatusKey.ListTask),
            photos: <String, Photo>{},
          ),
        );
        setStore(store);

        netQueue = MockNetQueue();
        setNetQueue(netQueue);
        setDataHome("project_home");
      });

      testWidgets('add item succ', (WidgetTester tester) async {
        // mock import photo
        String resourcePath = "test_resources/photo_test.jpg";
        while (File(resourcePath).existsSync() != true) {
          resourcePath = path.join("..", resourcePath);
        }

        MockCommandChannel mcc = MockCommandChannel();
        when(mcc.importPhoto()).thenAnswer((invoke) async {
          getStore().dispatch(ChangeStatusWithPathAction(
            status: StatusKey.AddingPhoto,
            path: resourcePath,
          ));
        });
        setCommandChannel(mcc);

        var widget = buildTestableWidget(HomePage(title: 'title'));
        await tester.pumpWidget(widget);

        // Add Button here
        expect(find.byType(TextButton), findsNWidgets(2));
        expect(find.text('ADD PHOTO'), findsOneWidget);

        // Tap 'ADD' button
        await tester.tap(find.text('ADD PHOTO'));
        await tester.pump();

        verify(mcc.importPhoto()).called(1);

        expect(store.state.status.status, StatusKey.AddingPhoto);
        expect(store.state.status.param1, resourcePath);

        // Show the selected image
        expect(find.byType(TextButton), findsNWidgets(2));
        expect(find.text("ADD"), findsOneWidget);
        expect(find.text("CANCEL"), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);

        Image img = find.byType(Image).evaluate().single.widget as Image;
        expect(img.image is FileImage, true);

        FileImage imgProvider = img.image as FileImage;
        expect(imgProvider.file.path, resourcePath);

        // click 'ADD'
        await tester.tap(find.text("ADD"));
        await tester.pump();

        // Photo is in redux list
        expect(store.state.status.status, StatusKey.ListTask);
        expect(store.state.photos.length, 1);

        var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        var photo = store.state.photos.values.first;
        expect(photo.filename, "photo_test.jpg");
        expect(photo.mime, "image/jpeg");
        expect(photo.size, "5938");
        expect(photo.hasOrigin, true);
        expect(photo.hasThumb, false);
        expect(photo.deleted, 0);
        expect(photo.updatedAt, lessThan(now + 1000));
        expect(photo.updatedAt, greaterThan(now - 5000));
        expect(photo.updatedAt, photo.createdAt);

        // No thumbnail, show indicator
        expect(find.text('ADD PHOTO'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        verify(netQueue.addQueueItem(
          QueueItemType.Photo,
          QueueItemAction.DownloadThumbnail,
          photo.uuid,
        )).called(1);
      });
    },
  );
}
