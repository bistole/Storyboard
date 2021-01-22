import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/views/common/app_icons.dart';

class ReduxActions {
  final String serverKey;
  final Reachable serverReachable;

  ReduxActions({
    @required this.serverKey,
    @required this.serverReachable,
  });
}

const LabelWidth = 80.0;

class ServerQRCode extends StatelessWidget {
  Widget buildTitle(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 4),
      child: Text(
        "Access Point Info",
        style: Theme.of(context).textTheme.headline2.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }

  Widget buildQRCode(ReduxActions redux) {
    return Row(
      children: [
        Container(
          width: LabelWidth,
          child: Text('QR Code:'),
        ),
        QrImage(
          data: redux.serverKey,
          version: QrVersions.auto,
          size: 200,
          padding: EdgeInsets.all(5),
        )
      ],
    );
  }

  Widget buildServerKey(BuildContext context, ReduxActions redux) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        width: LabelWidth,
        child: Text(
          'Server Key:',
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Colors.black),
        ),
      ),
      Expanded(
        child: Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(4),
          child: Text(
            redux.serverKey,
            style: Theme.of(context).textTheme.headline2.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      )
    ]);
  }

  Widget buildLaunched(BuildContext context, ReduxActions redux) {
    var icon = redux.serverReachable == Reachable.Unknown
        ? Icon(AppIcons.help, color: Colors.grey)
        : (redux.serverReachable == Reachable.Yes
            ? Icon(AppIcons.ok, color: Colors.green)
            : Icon(AppIcons.cancel, color: Colors.red));

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        width: LabelWidth,
        child: Text(
          'Status:',
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Colors.black),
        ),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
        child: icon,
      ),
    ]);
  }

  Widget buildDescription(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
            text: 'Scan QR Code or set server key in ',
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: 'Storyboard Mobile',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              TextSpan(text: ' to connect this app.'),
            ]),
      ),
    );
  }

  Widget buildNotAvailable() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: Colors.grey),
      ),
      child: Text(
        'N/A',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 48, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          serverKey: store.state.setting.serverKey,
          serverReachable: store.state.setting.serverReachable,
        );
      },
      builder: (context, ReduxActions redux) {
        if (redux.serverKey == "") {
          return Column(children: [
            buildTitle(context),
            buildNotAvailable(),
          ]);
        }
        return Column(children: [
          buildTitle(context),
          buildQRCode(redux),
          buildServerKey(context, redux),
          buildLaunched(context, redux),
          buildDescription(context),
        ]);
      },
    );
  }
}
