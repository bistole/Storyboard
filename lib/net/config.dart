import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const URLPrefix = "http://localhost:3000";

http.Client _internal;

// GetHTTPClient return http client.
http.Client getHTTPClient() {
  if (_internal == null) {
    _internal = http.Client();
  }
  return _internal;
}

// SetHTTPClient set customized http client, for testing
void setHTTPClient(http.Client client) {
  _internal = client;
}

String _dataHome;

String getDataHome() {
  return _dataHome;
}

Future<void> initDataHome() async {
  Directory dict = await getApplicationSupportDirectory();
  _dataHome = dict.path;
}
