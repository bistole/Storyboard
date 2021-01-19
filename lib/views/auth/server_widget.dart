import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ServerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: QrImage(
        data: "https://localhost:3000/auth_is_important",
        version: QrVersions.auto,
        size: 400,
      ),
    );
  }
}
