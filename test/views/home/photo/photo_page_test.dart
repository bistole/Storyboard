import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/photo/photo_page.dart';

import '../../../common.dart';

class MockNetQueue extends Mock implements NetQueue {}

void main() {
  Store<AppState> store;
  MockNetQueue netQueue;

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

  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore(
      pr: PhotoRepo(
        photos: <String, Photo>{uuid: Photo.fromJson(photoJson)},
        lastTS: 0,
      ),
    );

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

  testWidgets('show detail', (WidgetTester tester) async {
    // show detail but origin is not downloaded
    Widget w = buildTestableWidget(
      PhotoPage(PhotoPageArguments(uuid, 0)),
      store,
    );
    await tester.pumpWidget(w);

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
    String homePath = getHomePath("test_resources/home/");
    expect(
      imgDetailProvider.file.path,
      path.join(homePath, 'photos', uuid),
    );
  });
}
