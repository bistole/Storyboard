import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/views/auth/page.dart';

import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/logger/page.dart';
import 'package:storyboard/views/photo/page.dart';

class StoryBoardApp extends StatelessWidget {
  // This widget is the root of your application.
  StoryBoardApp();

  Widget buildNotAvailableWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: Text(
                "Hello, Storyboard",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              margin: EdgeInsets.symmetric(vertical: 16.0),
            ),
            CircularProgressIndicator(),
          ],
        )
      ],
    );
  }

  Future<Store<AppState>> getFutureStore() async {
    try {
      await getFactory().initMethodChannels();
      await getFactory().initStoreAndStorage();
      await getFactory().checkServerStatus();
    } catch (e, trace) {
      print(e);
      print(trace);
    }
    return getFactory().store;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Store<AppState>>(
      future: getFutureStore(),
      builder: (context, AsyncSnapshot<Store<AppState>> snapshot) {
        if (!snapshot.hasData) {
          return buildNotAvailableWidget();
        }

        return StoreProvider(
          store: snapshot.data,
          child: MaterialApp(
            title: 'Storyboard',
            routes: {
              PhotoPage.routeName: (_) => PhotoPage(),
              AuthPage.routeName: (_) => AuthPage(),
              LoggerPage.routeName: (_) => LoggerPage(),
            },
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: TextTheme(
                headline2: TextStyle(
                  fontSize: 18.0,
                ),
                headline3: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Theme.of(context).colorScheme.primary;
                      }
                      return null; // Use the component's default.
                    },
                  ),
                ),
              ),
            ),
            home: HomePage(title: 'Storyboard'),
          ),
        );
      },
    );
  }
}
