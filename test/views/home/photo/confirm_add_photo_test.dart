import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_view/photo_view.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';

import '../../../common.dart';

class MockNetQueue extends Mock implements NetQueue {}

void main() {
  NetQueue netQueue;
  Store<AppState> store;

  group('CreatePhotoPage', () {
    setUp(() {
      setFactoryLogger(MockLogger());
      getFactory().store = store = getMockStore();

      Storage s = Storage();
      String homePath = getHomePath("test_resources/home/");
      s.setDataHome(homePath);
      Directory(path.join(homePath, 'photos')).createSync(recursive: true);

      netQueue = MockNetQueue();
      getViewResource().storage = s;
      getViewResource().storage.setLogger(MockLogger());
      getViewResource().actPhotos = ActPhotos();
      getViewResource().actPhotos.setLogger(MockLogger());
      getViewResource().actPhotos.setNetQueue(netQueue);
      getViewResource().actPhotos.setStorage(s);
    });

    tearDown(() {
      String homePath = getHomePath("test_resources/home/");
      Directory(path.join(homePath, 'photos')).deleteSync(recursive: true);
    });

    testWidgets('click ok', (WidgetTester tester) async {
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");

      Widget w = buildTestableWidget(
        CreatePhotoPage(CreatePhotoPageArguments(resourcePath)),
        store,
      );
      await tester.pumpWidget(w);

      // Show the selected image
      expect(find.byType(SBToolbarButton), findsNWidgets(2));
      expect(find.text("OK"), findsOneWidget);
      expect(find.text("CANCEL"), findsOneWidget);
      expect(find.byType(PhotoView), findsOneWidget);

      PhotoView img =
          find.byType(PhotoView).evaluate().single.widget as PhotoView;
      expect(img.imageProvider is FileImage, true);

      FileImage imgProvider = img.imageProvider as FileImage;
      expect(imgProvider.file.path, resourcePath);

      // click 'OK'
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      // Photo is in redux list
      expect(store.state.status.status, StatusKey.ListPhoto);
      expect(store.state.photoRepo.photos.length, 1);

      var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      var photo = store.state.photoRepo.photos.values.first;
      expect(photo.filename, "photo_test.jpg");
      expect(photo.mime, "image/jpeg");
      expect(photo.size, "5938");
      expect(photo.hasOrigin, PhotoStatus.Ready);
      expect(photo.hasThumb, PhotoStatus.None);
      expect(photo.deleted, 0);
      expect(photo.updatedAt, lessThan(now + 1000));
      expect(photo.updatedAt, greaterThan(now - 5000));
      expect(photo.updatedAt, photo.createdAt);

      // navigator popped.
      expect(find.text('OK'), findsNothing);

      verify(netQueue.addQueueItem(
        QueueItemType.Photo,
        QueueItemAction.Upload,
        photo.uuid,
      )).called(1);
    });
  });
}
