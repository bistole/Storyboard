import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/helper/image_helper.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/logger/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';
import 'package:storyboard/views/photo/photo_page.dart';

import 'helper/route_aware_widget.dart';

class MockLogger extends Mock implements Logger {}

class MockNetQueue extends Mock implements NetQueue {}

class MockHttpClient extends Mock implements http.Client {}

class MockNavigatorObserver extends Mock implements RouteObserver<PageRoute> {}

class MockImageHelper extends Mock implements ImageHelper {}

MaterialPageRoute onMockGenerateRoute(RouteSettings settings) {
  Map<String, WidgetBuilder> routes = {
    HomePage.routeName: (_) =>
        RouteAwareWidget(HomePage.routeName, child: HomePage()),
    PhotoPage.routeName: (_) => RouteAwareWidget(
          PhotoPage.routeName,
          child: PhotoPage(settings.arguments as PhotoPageArguments),
        ),
    CreatePhotoPage.routeName: (_) => RouteAwareWidget(
          CreatePhotoPage.routeName,
          child:
              CreatePhotoPage(settings.arguments as CreatePhotoPageArguments),
        ),
    AuthPage.routeName: (_) => RouteAwareWidget(
          AuthPage.routeName,
          child: AuthPage(),
        ),
    LoggerPage.routeName: (_) => RouteAwareWidget(
          LoggerPage.routeName,
          child: LoggerPage(),
        ),
  };
  return MaterialPageRoute(builder: routes[settings.name], settings: settings);
}

String getResourcePath(String relativePath) {
  int cnt = 0;
  String resourcePath = relativePath;
  while (File(resourcePath).existsSync() != true) {
    resourcePath = path.join("..", resourcePath);
    if (++cnt > 20) {
      throw new Exception("can not find resource file: $relativePath");
    }
  }
  return File(resourcePath).absolute.path;
}

String getHomePath(String relativePath) {
  int cnt = 0;
  String resourcePath = relativePath;
  while (Directory(resourcePath).existsSync() != true) {
    resourcePath = path.join("..", resourcePath);
    if (++cnt > 20) {
      throw new Exception("can not find resource file: $relativePath");
    }
  }
  return Directory(resourcePath).absolute.path;
}

Store<AppState> getMockStore({
  Status status,
  PhotoRepo pr,
  NoteRepo nr,
  Queue q,
  Setting setting,
}) {
  return Store<AppState>(
    appReducer,
    initialState: AppState(
      status: status != null ? status : Status.noParam(StatusKey.ListPhoto),
      photoRepo:
          pr != null ? pr : PhotoRepo(photos: <String, Photo>{}, lastTS: 0),
      noteRepo: nr != null ? nr : NoteRepo(notes: {}, lastTS: 0),
      queue: q != null ? q : Queue(),
      setting: setting != null
          ? setting
          : Setting(
              clientID: 'client-id',
              serverKey: 'server-key',
              serverReachable: Reachable.Unknown,
            ),
    ),
  );
}

Widget buildTestableWidget(
  Widget widget,
  Store<AppState> store, {
  NavigatorObserver navigator,
}) {
  return StoreProvider(
    store: store,
    child: MaterialApp(
      onGenerateRoute: onMockGenerateRoute,
      home: RouteAwareWidget("", child: widget),
      navigatorObservers: navigator != null ? [navigator] : [],
    ),
  );
}

// need to tap before use
Widget buildTestablePageWithArguments(
    Widget widget, Store<AppState> store, Object args) {
  final key = GlobalKey<NavigatorState>();
  return StoreProvider(
    store: store,
    child: MaterialApp(
      navigatorKey: key,
      onGenerateRoute: onMockGenerateRoute,
      home: TextButton(
        onPressed: () => key.currentState.push(MaterialPageRoute(
          settings: RouteSettings(arguments: args),
          builder: (_) => widget,
        )),
        child: SizedBox(),
      ),
    ),
  );
}

Widget buildTestableWidgetInMaterial(Widget widget, Store<AppState> store) {
  return StoreProvider(
    store: store,
    child: MaterialApp(
      home: Scaffold(body: widget),
    ),
  );
}

Future<void> mockImageHelper(WidgetTester tester, String resourcePath) async {
  // read pic to buff
  var f = File(resourcePath);
  Uint8List bytes = f.readAsBytesSync();

  // codec
  final ui.Codec codec =
      await tester.runAsync(() => ui.instantiateImageCodec(bytes));

  // frame info
  final ui.FrameInfo fi = await tester.runAsync(codec.getNextFrame);

  ImageHelper realHelper = ImageHelper();
  ImageHelper mockHelper = MockImageHelper();
  when(mockHelper.loadImage(any)).thenAnswer((_) async {
    return fi.image;
  });
  when(mockHelper.rotateImage(any, any)).thenAnswer((_) async {
    return realHelper.rotateImage(fi.image, Constant.directionPortrait);
  });

  setImageHelper(mockHelper);
}
