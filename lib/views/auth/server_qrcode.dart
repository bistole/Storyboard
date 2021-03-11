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
    return Wrap(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Text(
            "Access Point Info",
            style: Theme.of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget buildStatus(BuildContext context, ReduxActions redux) {
    var icon = redux.serverReachable == Reachable.Unknown
        ? Icon(AppIcons.help, color: Colors.grey)
        : (redux.serverReachable == Reachable.Yes
            ? Icon(AppIcons.ok, color: Colors.green)
            : Icon(AppIcons.cancel, color: Colors.red));
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
      },
      children: <TableRow>[
        TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.top,
            child: Text(
              'QR Code:',
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  .copyWith(color: Colors.black),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 320, maxHeight: 320),
            child: QrImage(
              data: redux.serverKey,
              version: QrVersions.auto,
              padding: EdgeInsets.all(5),
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            'Server Key:',
            style: Theme.of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black),
          ),
          Text(
            redux.serverKey,
            style: Theme.of(context).textTheme.headline2.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ]),
        TableRow(children: [
          Text(
            'Status:',
            style: Theme.of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black),
          ),
          Align(alignment: Alignment.centerLeft, child: icon),
        ]),
      ],
    );
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
          return ListView(shrinkWrap: true, children: [
            buildTitle(context),
            buildNotAvailable(),
          ]);
        }
        return ListView(shrinkWrap: true, children: [
          buildTitle(context),
          buildStatus(context, redux),
          buildDescription(context),
        ]);
      },
    );
  }
}
