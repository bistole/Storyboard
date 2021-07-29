import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/views/auth/page.dart';
import 'package:storyboard/views/common/warning_messager.dart';

class ReduxActions {
  final Reachable serverReachable;
  final String serverKey;
  ReduxActions({this.serverKey, this.serverReachable});
}

class ServerStatusWarningMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          serverKey: store.state.setting.serverKey,
          serverReachable: store.state.setting.serverReachable,
        );
      },
      builder: (BuildContext context, ReduxActions redux) {
        RichText text;
        VoidCallback forward;
        if (redux.serverKey == null || redux.serverKey.length == 0) {
          text = WarningMessager.configServerWarningText(context);
          forward = () {
            Navigator.of(context).pushNamed(
              AuthPage.routeName,
            );
          };
        } else if (redux.serverReachable == Reachable.Unknown) {
          text = WarningMessager.configUnknownServerReachable(context);
        } else if (redux.serverReachable == Reachable.No) {
          text = WarningMessager.configServerUnreachable(context);
          forward = () {
            Navigator.of(context).pushNamed(
              AuthPage.routeName,
            );
          };
        }
        if (text != null) {
          if (forward != null) {
            return WarningMessager(text, forward: forward);
          } else {
            return WarningMessager(text);
          }
        }
        return Container();
      },
    );
  }
}
