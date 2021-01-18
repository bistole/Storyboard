import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final String serverKey;
  ReduxActions({this.serverKey});
}

class AuthPage extends StatelessWidget {
  static const routeName = '/auth';

  Widget buildClientAuth() {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          serverKey: store.state.setting.serverKey ?? "",
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Expanded(
                child: TextButton(
                  onPressed: getViewResource().command.takeQRCode,
                  child: Text('Scan'),
                ),
              ),
              Expanded(
                child: Text(
                  redux.serverKey,
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget buildServerAuth() {
    return Container(
      alignment: Alignment.center,
      child: QrImage(
        data: "https://localhost:3000/auth_is_important",
        version: QrVersions.auto,
        size: 400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: getViewResource().deviceManager.isDesktop()
          ? buildServerAuth()
          : buildClientAuth(),
    );
  }
}
