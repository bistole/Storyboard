import 'package:flutter/material.dart';
import 'package:storyboard/views/auth/log_entrance.dart';
import 'package:storyboard/views/auth/server_picker.dart';
import 'package:storyboard/views/auth/server_qrcode.dart';
import 'package:storyboard/views/auth/version_widget.dart';
import 'package:storyboard/views/config/styles.dart';

class ServerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ServerQRCode(),
            Styles.divider,
            ServerPicker(),
            Styles.divider,
            LogEntrance(),
            VersionWidget(),
          ],
        ),
      ),
    );
  }
}
