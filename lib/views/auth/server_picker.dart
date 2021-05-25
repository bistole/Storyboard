import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';

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

    getViewResource().backend.setCurrentIp(ip).then(
          (_) => getViewResource().backend.getCurrentIp().then(
                (retIP) => changeServerKey(encodeServerKey(retIP, 3000)),
              ),
        );
  }

  void getBackendInfo() {
    if (currentIP == "") {
      getViewResource().backend.getCurrentIp().then(
            (value) => this.setState(() {
              currentIP = value;
            }),
          );
    }
    if (availableIPs.length == 0) {
      getViewResource().backend.getAvailableIps().then(
            (value) => this.setState(() {
              availableIPs = value;
            }),
          );
    }
  }

  Widget buildTitle(BuildContext context) {
    return Wrap(
      children: [
        Text(
          "Alternatives:",
          style: Styles.titleTextStyle,
        ),
      ],
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
            color: Styles.unselectedBackColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(width: 1, color: Styles.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(AppIcons.check, color: Styles.unselectedColor),
              Container(
                margin: EdgeInsets.only(left: 4),
                child: Text(element.key.toUpperCase(),
                    style: TextStyle(color: Styles.unselectedColor)),
              ),
            ],
          ),
        ));
      } else {
        result.add(Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Styles.selectedBackColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(width: 1, color: Styles.borderColor),
          ),
          child: InkWell(
            onTap: () {
              this.changeIP(element.value, redux.changeServerKey);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(AppIcons.check_empty, color: Styles.selectedColor),
                Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text(element.key.toUpperCase(),
                        style: TextStyle(color: Styles.selectedColor))),
              ],
            ),
          ),
        ));
      }
    });
    return result;
  }

  Widget buildDescription(BuildContext context) {
    return Wrap(
      children: [
        RichText(
          text: TextSpan(
            text: 'If',
            style: Styles.lessBodyText,
            children: <TextSpan>[
              TextSpan(
                text: ' Storyboard Mobile ',
                style: Styles.boldBodyText,
              ),
              TextSpan(
                text:
                    'failed to this app, try other access points listed above.',
              )
            ],
          ),
        ),
      ],
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
      return ListView(
        shrinkWrap: true,
        children: [
          buildTitle(context),
          ...buildSelector(context, redux),
          buildDescription(context),
        ],
      );
    });
  }
}
