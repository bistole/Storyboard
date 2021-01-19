import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/button.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final String serverKey;
  final Function(String) changeServerKey;
  final TextEditingController serverKeyController;

  ReduxActions({this.serverKey, this.changeServerKey})
      : serverKeyController = TextEditingController(text: serverKey);
}

class ClientWidget extends StatefulWidget {
  @override
  _ClientWidgetState createState() => _ClientWidgetState();
}

class _ClientWidgetState extends State<ClientWidget> {
  bool editing;

  @override
  void initState() {
    editing = false;
    super.initState();
  }

  void startToEditing() {
    setState(() {
      editing = true;
    });
  }

  void endEditing() {
    setState(() {
      editing = false;
    });
  }

  Widget buildLocationTitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.centerLeft,
      child: Text(
        "Location of desktop app:",
        textAlign: TextAlign.left,
        style: Theme.of(context)
            .textTheme
            .headline2
            .copyWith(color: Theme.of(context).primaryColor),
      ),
    );
  }

  List<Widget> buildDisplayLocation(BuildContext context, ReduxActions redux) {
    return [
      buildLocationTitle(context),
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
      buildLocationTitle(context),
      Row(children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: RawKeyboardListener(
              child: TextField(
                controller: redux.serverKeyController,
                onSubmitted: (String serverKey) {
                  redux.changeServerKey(serverKey);
                  endEditing();
                },
                autofocus: true,
                decoration: InputDecoration(hintText: '127.0.0.1:3000'),
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
      ])
    ];
  }

  List<Widget> buildScanButtons(BuildContext context) {
    return [
      Row(children: [
        Expanded(
          child: SBButton(
            getViewResource().command.takeQRCode,
            text: 'Scan QR Code',
          ),
        ),
        Spacer(),
      ]),
      Row(
        children: [
          Expanded(
            child: SBButton(
              startToEditing,
              text: 'Change Manually',
            ),
          ),
          Spacer(),
        ],
      ),
    ];
  }

  List<Widget> buildEditButtons(BuildContext context, ReduxActions redux) {
    return [
      Row(children: [
        Spacer(flex: 2),
        Expanded(
          child: SBButton(
            () {
              redux.changeServerKey(redux.serverKeyController.text);
              endEditing();
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
          changeServerKey: (String serverKey) => store.dispatch(
            SettingServerKeyAction(serverKey: serverKey),
          ),
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: editing
                ? [
                    Spacer(),
                    ...buildEditLocation(context, redux),
                    ...buildEditButtons(context, redux),
                    Spacer(flex: 2),
                  ]
                : [
                    Spacer(),
                    ...buildDisplayLocation(context, redux),
                    ...buildScanButtons(context),
                    Spacer(flex: 2),
                  ],
          ),
        );
      },
    );
  }
}
