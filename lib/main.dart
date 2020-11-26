import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';

import 'models/app.dart';
import 'net/tasks.dart';
import 'reducers/app_reducer.dart';
import 'views/home/page.dart';

void main() async {
  // final persistor = Persistor<AppState>(
  //   storage: FileStorage(File("state.json")),
  //   serializer: JsonSerializer<AppState>(AppState.fromJson),
  // );

  // final initialState = await persistor.load();

  final store = new Store<AppState>(
    appReducer,
    initialState: new AppState(),
  );

  await fetchTasks(store);

  runApp(new StoryBoardApp(store: store));
}

class StoryBoardApp extends StatelessWidget {
  // This widget is the root of your application.
  final Store<AppState> store;

  StoryBoardApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              primary: Colors.green,
            ))),
        home: HomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
