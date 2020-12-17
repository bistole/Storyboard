import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import './store.dart';
import 'models/app.dart';
import 'views/home/page.dart';

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
