import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

class MockLogger extends Mock implements Logger {}

class MockHttpClient extends Mock implements http.Client {}

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
  TaskRepo tr,
  Queue q,
  Setting setting,
}) {
  return Store<AppState>(
    appReducer,
    initialState: AppState(
      status: status != null ? status : Status.noParam(StatusKey.ListPhoto),
      photoRepo:
          pr != null ? pr : PhotoRepo(photos: <String, Photo>{}, lastTS: 0),
      taskRepo: tr != null ? tr : TaskRepo(tasks: {}, lastTS: 0),
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

Widget buildTestableWidget(Widget widget, Store<AppState> store) {
  return StoreProvider(
    store: store,
    child: MaterialApp(
      home: widget,
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
