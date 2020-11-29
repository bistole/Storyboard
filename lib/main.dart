import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'models/app.dart';
import 'net/tasks.dart';
import 'reducers/app_reducer.dart';
import 'views/home/page.dart';

Future<Store<AppState>> initStore() async {
  Directory dic = await getApplicationSupportDirectory();
  final statePath = path.join(dic.path, 'state.json');

  final persistor = Persistor<AppState>(
    storage: FileStorage(File(statePath)),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  final initialState = await persistor.load();

  final store = new Store<AppState>(
    appReducer,
    initialState: initialState,
    middleware: [persistor.createMiddleware()],
  );

  // Use timer to trigger fetchTasks after launch
  Future.delayed(Duration(seconds: 30), () {
    fetchTasks(store);
  });
  return store;
}

void main() async {
  runApp(new StoryBoardApp());
}

class StoryBoardApp extends StatelessWidget {
  // This widget is the root of your application.
  StoryBoardApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Store<AppState>>(
      future: initStore(),
      builder: (context, AsyncSnapshot<Store<AppState>> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return new StoreProvider(
          store: snapshot.data,
          child: new MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.green,
                ),
              ),
            ),
            home: HomePage(title: 'Flutter Demo Home Page'),
          ),
        );
      },
    );
  }
}
