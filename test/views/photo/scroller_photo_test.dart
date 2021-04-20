import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';

import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/origin_photo_widget.dart';
import 'package:storyboard/views/photo/photo_scroller_widget.dart';

import '../../common.dart';
import '../home/photo/add_photo_test.dart';

void main() {
  Store<AppState> store;
  String homePath;

  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();

    Storage s = Storage();
    homePath = getHomePath("test_resources/home/") + "A005/";
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

  group('Scroller', () {
    testWidgets('rotate or reset', (WidgetTester tester) async {
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      await mockImageHelper(tester, resourcePath);

      getViewResource().notifier = MockNotifier();
      when(getViewResource().notifier.getValue<int>(Constant.eventPhotoRotate))
          .thenReturn(180);

      var w =
          buildTestableWidget(PhotoScollerWidget(path: resourcePath), store);
      await tester.pumpWidget(w);
      await tester.pumpAndSettle();

      expect(find.byType(OriginPhotoWidget), findsOneWidget);

      var capRegister =
          verify(getViewResource().notifier.registerNotifier(captureAny))
              .captured;
      expect(capRegister[0], Constant.eventPhotoReset);
      expect(capRegister[1], Constant.eventPhotoRotate);

      var capListener =
          verify(getViewResource().notifier.addListener(captureAny, captureAny))
              .captured;
      expect(capListener[0], Constant.eventPhotoReset);
      expect(capListener[2], Constant.eventPhotoRotate);

      // do reset
      await capListener[1]();
      await tester.pumpAndSettle();

      // do rotate
      await capListener[3]();
      await tester.pumpAndSettle();

      var capGetValue =
          verify(getViewResource().notifier.getValue(captureAny)).captured.last;
      expect(capGetValue, Constant.eventPhotoRotate);
    });
  });
}
