import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/common/app_icons.dart';

class ReduxActions {
  final Reachable reachable;
  ReduxActions({@required this.reachable});
}

class ServerStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (Store<AppState> store) {
        return ReduxActions(reachable: store.state.setting.serverReachable);
      },
      builder: (BuildContext context, ReduxActions redux) {
        var color =
            redux.reachable == Reachable.Yes ? Colors.white : Colors.red;
        return TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AuthPage.routeName,
            );
          },
          icon: Icon(AppIcons.qrcode, color: color),
          label: Text(""),
        );
      },
    );
  }
}
