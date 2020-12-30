import 'dart:io';

import 'package:path_provider/path_provider.dart';

String _dataHome;

String getDataHome() {
  return _dataHome;
}

Future<void> initDataHome() async {
  Directory dict = await getApplicationSupportDirectory();
  _dataHome = dict.path;
}
