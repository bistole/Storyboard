import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/views/auth/log_entrance.dart';
import 'package:storyboard/views/auth/version_widget.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/button.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final String serverKey;
  final Reachable serverReachable;
  final Function(String) changeServerKey;
  final TextEditingController serverKeyController;

  ReduxActions({this.serverKey, this.serverReachable, this.changeServerKey})
      : serverKeyController = TextEditingController(text: serverKey);
}

const LabelWidth = 80.0;

class ClientWidget extends StatefulWidget {
  @override
  _ClientWidgetState createState() => _ClientWidgetState();
}

const ErrorInvalidServerKey = 'Invalid Server Key';
const ErrorInvalidScanner = 'Invalid QR Code';

class _ClientWidgetState extends State<ClientWidget> {
  bool editing;
  String editingError;

  @override
  void initState() {
    editing = false;
    editingError = null;
    super.initState();
  }

  void startToEditing() {
    setState(() {
      editing = true;
      editingError = null;
    });
  }

  void endEditing() {
    setState(() {
      editing = false;
    });
  }

  void errorEditing(String error) {
    setState(() {
      editingError = error;
    });
  }

  void alertInvalidQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext conext) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(ErrorInvalidScanner),
          actions: [
            TextButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 4),
      child: Text(
        "Current Access Point",
        style: Theme.of(context).textTheme.headline2.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }

  List<Widget> buildDisplayLocation(BuildContext context, ReduxActions redux) {
    return [
      Row(children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColorDark),
            ),
            child: Text(
              redux.serverKey ?? "NONE",
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
        ),
      ])
    ];
  }

  List<Widget> buildEditLocation(BuildContext context, ReduxActions redux) {
    return [
      Row(children: [
        Expanded(
          child: Container(
            child: RawKeyboardListener(
              child: TextField(
                controller: redux.serverKeyController,
                onSubmitted: (String serverKey) {
                  var code = serverKey.toLowerCase();
                  if (decodeServerKey(code) != null) {
                    redux.changeServerKey(code);
                    endEditing();
                  } else {
                    errorEditing(ErrorInvalidServerKey);
                  }
                },
                autofocus: true,
                decoration: InputDecoration(
                    hintText: encodeServerKey('127.0.0.1', 3000)),
              ),
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
                  endEditing();
                }
              },
            ),
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              this.editingError == null ? '' : ('* ' + this.editingError),
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  .copyWith(color: Colors.red),
            ),
          ),
        ),
      ]),
    ];
  }

  Widget buildLaunched(BuildContext context, ReduxActions redux) {
    var reachable = redux.serverReachable;

    var desc = reachable == Reachable.Unknown
        ? 'Unknown'
        : (reachable == Reachable.Yes ? 'Reachable' : 'Unreachable');

    var color = reachable == Reachable.Unknown
        ? Colors.grey
        : (reachable == Reachable.Yes ? Colors.green : Colors.red);

    var icon = reachable == Reachable.Unknown
        ? Icon(AppIcons.help, color: color)
        : (reachable == Reachable.Yes
            ? Icon(AppIcons.ok, color: color)
            : Icon(AppIcons.cancel, color: color));

    return Row(
      children: [
        Expanded(
          child: Text(
            'Access Point Status:',
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(color: Colors.black),
          ),
        ),
        icon,
        Expanded(
          child: Text(
            desc,
            style: Theme.of(context).textTheme.headline3.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  List<Widget> buildScanButtons(BuildContext context) {
    return [
      Row(children: [
        Expanded(
          child: SBButton(
            () => getViewResource()
                .command
                .takeQRCode()
                .catchError((_) => alertInvalidQRCode()),
            text: 'Scan QR Code',
          ),
        ),
        Expanded(
          child: SBButton(
            startToEditing,
            text: 'Change Manually',
          ),
        ),
      ]),
    ];
  }

  List<Widget> buildEditButtons(BuildContext context, ReduxActions redux) {
    return [
      Row(children: [
        Spacer(flex: 2),
        Expanded(
          child: SBButton(
            () {
              var code = redux.serverKeyController.text.toLowerCase();
              if (decodeServerKey(code) != null) {
                redux.changeServerKey(code);
                endEditing();
              } else {
                errorEditing(ErrorInvalidServerKey);
              }
            },
            text: 'Save',
          ),
        ),
        Expanded(
          child: SBButton(
            endEditing,
            text: 'Cancel',
          ),
        ),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          serverKey: store.state.setting.serverKey,
          serverReachable: store.state.setting.serverReachable,
          changeServerKey: (String serverKey) {
            getViewResource().actServer.actChangeServerKey(store, serverKey);
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: editing
                ? [
                    buildTitle(context),
                    ...buildEditLocation(context, redux),
                    ...buildEditButtons(context, redux),
                    Divider(color: Colors.grey),
                    LogEntrance(),
                    VersionWidget(),
                  ]
                : [
                    buildTitle(context),
                    ...buildDisplayLocation(context, redux),
                    buildLaunched(context, redux),
                    ...buildScanButtons(context),
                    Divider(color: Colors.grey),
                    LogEntrance(),
                    VersionWidget(),
                  ],
          ),
        );
      },
    );
  }
}
