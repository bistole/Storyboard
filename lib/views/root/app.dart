import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';

import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/logger/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';
import 'package:storyboard/views/photo/photo_page.dart';

class ReduxActions {
  Status status;
  Function createNote;
  ReduxActions({this.status, this.createNote});
}

class StoryBoardApp extends StatelessWidget {
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

  Widget buildMaterialApp(BuildContext context, Widget innerWidget) {
    return MaterialApp(
      title: 'Storyboard',
      onGenerateRoute: StoryBoardApp.onGenerateRoute,
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
      home: innerWidget,
    );
  }

  Widget buildChild(ReduxActions redux) {
    // share photo
    if (redux.status.status == StatusKey.ShareInPhoto) {
      return CreatePhotoPage(
        CreatePhotoPageArguments(redux.status.path),
      );
    }

    // share note
    if (redux.status.status == StatusKey.ShareInNote) {
      // TODO: may need an interface to confirm
      // redux.createNote(redux.status.text);
      return Text(redux.status.text);
    }

    return HomePage(title: 'Storyboard');
  }

  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (Store<AppState> store) {
        return ReduxActions(
            status: store.state.status,
            createNote: (String text) {
              // getViewResource().actNotes.actCreateNote(store, text);
              // store.dispatch(ChangeStatusAction(status: StatusKey.ListNote));
            });
      },
      builder: (BuildContext context, ReduxActions redux) {
        return buildMaterialApp(context, buildChild(redux));
      },
    );
  }
}
