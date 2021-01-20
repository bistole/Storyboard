import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/config/config.dart';

class ServerWidget extends StatefulWidget {
  @override
  _ServerWidgetState createState() => _ServerWidgetState();
}

class _ServerWidgetState extends State<ServerWidget> {
  String currentIP;
  Map<String, String> availableIPs;

  @override
  void initState() {
    currentIP = "";
    availableIPs = Map();
    super.initState();
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

  void changeIp(String ip) {
    getViewResource().command.setCurrentIp(ip).then(
      (_) {
        getViewResource().command.getCurrentIp().then(
              (value) => this.setState(() {
                currentIP = value;
              }),
            );
      },
    );
  }

  Widget buildLocationTitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
            text: 'Scan QR Code or set server key in ',
            style: Theme.of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: 'Storyboard Mobile',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              TextSpan(text: ' to connect '),
              TextSpan(
                text: 'Storyboard Desktop',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              TextSpan(text: '.'),
            ]),
      ),
    );
  }

  Widget buildLocationQRCode(BuildContext context) {
    if (currentIP == "") {
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
          'Not\nAvailable',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, color: Colors.grey),
        ),
      );
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          QrImage(
            data: "http://" + currentIP + ":3000/auth_is_important",
            version: QrVersions.auto,
            size: 200,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Server Key:',
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  .copyWith(color: Colors.black),
            ),
            Container(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
              ),
              child: Text(
                currentIP + ":3000",
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Colors.black),
              ),
            )
          ]),
        ],
      ),
    );
  }

  List<Widget> buildSelector() {
    var result = <Widget>[];
    result.add(Divider(color: Colors.grey));
    result.add(Text(
        'If Storyboard Mobile failed to connect desktop,' +
            'try another server key listed below:',
        style: Theme.of(context)
            .textTheme
            .headline2
            .copyWith(color: Colors.black)));

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
            this.changeIp(element.value);
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

  @override
  Widget build(BuildContext context) {
    getBackendInfo();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        buildLocationTitle(context),
        buildLocationQRCode(context),
        ...buildSelector(),
        Spacer(),
      ]),
    );
  }
}
