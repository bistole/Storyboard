import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class VersionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<String> getVersionName() async {
      PackageInfo info = await PackageInfo.fromPlatform();
      return info.version + "-" + info.buildNumber;
    }

    return FutureBuilder(
      future: getVersionName(),
      builder: (context, snapshot) {
        Widget w;
        if (!snapshot.hasData) {
          w = Text("Waiting");
        } else if (snapshot.hasError) {
          w = Text("Error");
        } else {
          w = Text(snapshot.data);
        }

        return Center(
          child: Container(
            padding: EdgeInsets.all(8),
            child: w,
          ),
        );
      },
    );
  }
}
