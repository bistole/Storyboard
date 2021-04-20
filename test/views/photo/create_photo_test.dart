import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';

import '../../common.dart';
import '../home/photo/add_photo_test.dart';

void main() {
  Store<AppState> store;
  String homePath;

  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();

    Storage s = Storage();
    homePath = getHomePath("test_resources/home/") + "A004/";
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

  group('CreatePhotoPage', () {
    testWidgets('rotate', (WidgetTester tester) async {
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      await mockImageHelper(tester, resourcePath);

      getViewResource().notifier = MockNotifier();

      Widget w = buildTestableWidget(
        CreatePhotoPage(CreatePhotoPageArguments(resourcePath)),
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

      await tester.tap(find.byIcon(AppIcons.angle_right));
      await tester.pumpAndSettle();

      var captured2 = verify(getViewResource()
              .notifier
              .notifyListeners(captureAny, param: captureAnyNamed('param')))
          .captured;
      expect(captured2[0] as String, Constant.eventPhotoRotate);
      expect(captured2[1] as int, 0);
    });

    testWidgets('reset', (WidgetTester tester) async {
      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      await mockImageHelper(tester, resourcePath);

      getViewResource().notifier = MockNotifier();

      Widget w = buildTestableWidget(
        CreatePhotoPage(CreatePhotoPageArguments(resourcePath)),
        store,
      );
      await tester.pumpWidget(w);

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
