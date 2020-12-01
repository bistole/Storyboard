import 'package:http/http.dart' as http;

const URLPrefix = "http://localhost:3000";

http.Client _internal = null;

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
