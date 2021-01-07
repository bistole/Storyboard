import 'dart:io';

import 'package:path_provider/path_provider.dart';

String _dataHome;

String getDataHome() {
  return _dataHome;
}

void setDataHome(String dh) {
  _dataHome = dh;
}

Future<void> initDataHome() async {
  Directory dict = await getApplicationSupportDirectory();
  _dataHome = dict.path;
}
