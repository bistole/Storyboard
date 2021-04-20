import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/photo/photo_list_widget.dart';
import 'package:storyboard/views/home/photo/photo_widget.dart';

import '../../../common.dart';

class MockMenuChannel extends Mock implements MenuChannel {}

class MockDeviceManager extends Mock implements DeviceManager {}

void main() {
  String homePath;
  Store<AppState> store;
  DeviceManager dm;

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
    '_ts': 0,
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
    homePath = getHomePath("test_resources/home/") + "A003/";
    Directory(path.join(homePath, 'photos')).createSync(recursive: true);
    s.setDataHome(homePath);

    dm = MockDeviceManager();

    getViewResource().deviceManager = dm;
    getViewResource().menu = MockMenuChannel();
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

  group('Desktop', () {
    setUp(() {
      when(dm.isMobile()).thenReturn(false);
      when(dm.isDesktop()).thenReturn(true);
    });
    testWidgets('.showMenu .hideMenu', (WidgetTester tester) async {
      Widget w = buildTestableWidget(PhotoListWidget(), store);
      await tester.pumpWidget(w, Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      Key key = getViewResource().getGlobalKeyByName("PHOTO-LIST:" + uuid);
      expect(find.byKey(key), findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byKey(key)));
      var st1 = tester.state(find.byType(PhotoWidget)) as PhotoWidgetState;
      expect(st1.isMenuShown, true);

      await gesture.moveTo(Offset.zero);
      var st2 = tester.state(find.byType(PhotoWidget)) as PhotoWidgetState;
      expect(st2.isMenuShown, false);
    });
  });

  group('Mobile', () {
    setUp(() {
      when(dm.isMobile()).thenReturn(true);
      when(dm.isDesktop()).thenReturn(false);
    });

    testWidgets('.showMenu', (WidgetTester tester) async {
      Widget w = buildTestableWidget(PhotoListWidget(), store);
      await tester.pumpWidget(w, Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      Key key = getViewResource().getGlobalKeyByName("PHOTO-LIST:" + uuid);
      expect(find.byKey(key), findsOneWidget);

      var rect = tester.getRect(find.byKey(key));

      await tester.dragFrom(
          rect.centerRight.translate(-5, 0), Offset(-100, -30));
      var st1 = tester.state(find.byType(PhotoWidget)) as PhotoWidgetState;
      expect(st1.isMenuShown, true);

      await tester.dragFrom(rect.centerLeft.translate(5, 0), Offset(100, 30));
      var st2 = tester.state(find.byType(PhotoWidget)) as PhotoWidgetState;
      expect(st2.isMenuShown, false);
    });
  });
}
