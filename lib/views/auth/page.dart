import 'package:flutter/material.dart';
import 'package:storyboard/views/auth/client_widget.dart';
import 'package:storyboard/views/auth/server_widget.dart';
import 'package:storyboard/views/config/config.dart';

class AuthPage extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Server Configuration'),
      ),
      body: getViewResource().deviceManager.isDesktop()
          ? ServerWidget()
          : ClientWidget(),
    );
  }
}
