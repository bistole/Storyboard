import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final Function(String) changeServerKey;

  ReduxActions({
    @required this.changeServerKey,
  });
}

class ServerPicker extends StatefulWidget {
  @override
  _ServerPickerState createState() => _ServerPickerState();
}

class _ServerPickerState extends State<ServerPicker> {
  String currentIP;
  Map<String, String> availableIPs;

  @override
  void initState() {
    currentIP = "";
    availableIPs = Map();
    super.initState();
  }

  void changeIP(String ip, void Function(String) changeServerKey) {
    if (currentIP == ip) return;
    setState(() {
      currentIP = ip;
    });

    getViewResource().command.setCurrentIp(ip).then(
          (_) => getViewResource().command.getCurrentIp().then(
                (value) => changeServerKey(encodeServerKey(currentIP, 3000)),
              ),
        );
  }

  void getBackendInfo() {
    if (currentIP == "") {
      getViewResource().command.getCurrentIp().then(
            (value) => this.setState(() {
              currentIP = value;
            }),
          );
    }
    if (availableIPs.length == 0) {
      getViewResource().command.getAvailableIps().then(
            (value) => this.setState(() {
              availableIPs = value;
            }),
          );
    }
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 4),
      child: Text(
        "Alternatives:",
        style: Theme.of(context).textTheme.headline2.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }

  List<Widget> buildSelector(context, ReduxActions redux) {
    var result = <Widget>[];
    availableIPs.entries.forEach((element) {
      if (element.value == this.currentIP) {
        result.add(Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(AppIcons.check, color: Colors.grey[700]),
              Container(
                margin: EdgeInsets.only(left: 4),
                child: Text(element.key.toUpperCase(),
                    style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        ));
      } else {
        result.add(InkWell(
          onTap: () {
            print("Choose ${element.key} to change ip to ${element.value}");
            this.changeIP(element.value, redux.changeServerKey);
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(AppIcons.check_empty, color: Colors.white),
                Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text(element.key.toUpperCase(),
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ));
      }
    });
    return result;
  }

  Widget buildDescription(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          text: 'If',
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Colors.grey),
          children: <TextSpan>[
            TextSpan(
              text: ' Storyboard Mobile ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
            ),
            TextSpan(
              text: 'failed to this app, try other access points listed above.',
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(converter: (store) {
      return ReduxActions(
        changeServerKey: (String serverKey) {
          getViewResource().actServer.actChangeServerKey(store, serverKey);
        },
      );
    }, builder: (context, ReduxActions redux) {
      getBackendInfo();
      return Column(children: [
        Divider(color: Colors.grey),
        buildTitle(context),
        ...buildSelector(context, redux),
        buildDescription(context),
      ]);
    });
  }
}
