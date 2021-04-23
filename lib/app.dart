import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/config/styles.dart';

import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/logger/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';
import 'package:storyboard/views/photo/photo_page.dart';

class StoryBoardApp extends StatelessWidget {
  // This widget is the root of your application.
  StoryBoardApp();

  Widget buildNotAvailableWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Text(
                  "Hello, Storyboard",
                  textDirection: TextDirection.ltr,
                  style: Styles.welcomeTextStyle,
                ),
                margin: EdgeInsets.symmetric(vertical: 16.0),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Future<Store<AppState>> getFutureStore() async {
    await getFactory().initCrashlytics();
    try {
      await getFactory().initMethodChannels();
      await getFactory().initStoreAndStorage();
      await getFactory().checkServerStatus();
    } catch (e, s) {
      await FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'when create store');
    }
    return Future.value(getFactory().store);
  }

  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    Map<String, WidgetBuilder> routes = {
      HomePage.routeName: (_) => HomePage(),
      PhotoPage.routeName: (_) =>
          PhotoPage(settings.arguments as PhotoPageArguments),
      CreatePhotoPage.routeName: (_) =>
          CreatePhotoPage(settings.arguments as CreatePhotoPageArguments),
      AuthPage.routeName: (_) => AuthPage(),
      LoggerPage.routeName: (_) => LoggerPage(),
    };
    return MaterialPageRoute(
        builder: routes[settings.name], settings: settings);
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
            onGenerateRoute: onGenerateRoute,
            theme: ThemeData(
              primarySwatch: Styles.primaryColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Theme.of(context).primaryColorDark;
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
