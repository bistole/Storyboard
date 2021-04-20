import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/photo_page.dart';

import '../../common.dart';
import '../home/photo/add_photo_test.dart';

void main() {
  Store<AppState> store;
  String homePath;

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

  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore(
      pr: PhotoRepo(
        photos: <String, Photo>{uuid: Photo.fromJson(photoJson)},
        lastTS: 0,
      ),
    );

    Storage s = Storage();
    homePath = getHomePath("test_resources/home/") + "A006/";
    Directory(path.join(homePath, 'photos')).createSync(recursive: true);
    s.setDataHome(homePath);

    getViewResource().storage = s;
    getViewResource().storage.setLogger(MockLogger());
    getViewResource().actPhotos = ActPhotos();
    getViewResource().actPhotos.setLogger(MockLogger());
    getViewResource().actPhotos.setNetQueue(MockNetQueue());
    getViewResource().actPhotos.setStorage(s);
  });

  tearDown(() {
    Directory(path.join(homePath, 'photos')).deleteSync(recursive: true);
  });

  group('PhotoPage', () {
    testWidgets('rotate', (WidgetTester tester) async {
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      await mockImageHelper(tester, resourcePath);

      getViewResource().notifier = MockNotifier();

      Widget w = buildTestableWidget(
        PhotoPage(PhotoPageArguments(uuid, 0)),
        store,
      );
      await tester.pumpWidget(w);

      expect(find.byIcon(AppIcons.angle_left), findsOneWidget);
      expect(find.byIcon(AppIcons.angle_right), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.angle_left));
      await tester.pumpAndSettle();

      var captured1 = verify(getViewResource()
              .notifier
              .notifyListeners(captureAny, param: captureAnyNamed('param')))
          .captured;
      expect(captured1[0] as String, Constant.eventPhotoRotate);
      expect(captured1[1] as int, 270);

      var photo1 = store.state.photoRepo.photos.values.first;
      expect(photo1.direction, 270);

      await tester.tap(find.byIcon(AppIcons.angle_right));
      await tester.pumpAndSettle();

      var captured2 = verify(getViewResource()
              .notifier
              .notifyListeners(captureAny, param: captureAnyNamed('param')))
          .captured;
      expect(captured2[0] as String, Constant.eventPhotoRotate);
      expect(captured2[1] as int, 0);

      var photo2 = store.state.photoRepo.photos.values.first;
      expect(photo2.direction, 0);
    });

    testWidgets('reset', (WidgetTester tester) async {
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      await mockImageHelper(tester, resourcePath);

      getViewResource().notifier = MockNotifier();

      Widget w = buildTestableWidget(
        PhotoPage(PhotoPageArguments(uuid, 0)),
        store,
      );
      await tester.pumpWidget(w);
      await tester.pumpAndSettle();

      expect(find.text('RESET'), findsOneWidget);
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();

      var captured =
          verify(getViewResource().notifier.notifyListeners(captureAny))
              .captured;
      expect(captured[0] as String, Constant.eventPhotoReset);
    });
  });
}
