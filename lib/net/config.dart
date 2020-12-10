import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

Map<String, EventChannel> _streams = <String, EventChannel>{};
Map<String, StreamSubscription> _hooks = <String, StreamSubscription>{};

String enableSubscription(String eventName, void Function(dynamic event) cb) {
  EventChannel stream;
  if (!_streams.containsKey(eventName)) {
    stream = EventChannel(eventName);
    _streams[eventName] = stream;
  } else {
    stream = _streams[eventName];
  }

  // ignore: cancel_subscriptions
  var sub = stream.receiveBroadcastStream().listen(cb);
  var hash = DateTime.now().millisecondsSinceEpoch.toString();
  var subKey = eventName + "@" + hash;
  _hooks[subKey] = sub;
  return subKey;
}

void disableSubscription(String subKey) {
  if (_hooks.containsKey(subKey)) {
    var sub = _hooks[subKey];
    _hooks.remove(subKey);
    sub.cancel();
  }
}
