import 'dart:io';

import 'package:redux/redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';

var countPerFetch = 100;

String encodeServerKey(String ip, int port) {
  const c2hex = '0123456789abcdef';
  var result = '';
  var iparr = ip.split('.');
  for (var ipseg in iparr) {
    var ipsegInt = int.parse(ipseg);
    result += c2hex[ipsegInt ~/ 16] + c2hex[ipsegInt % 16];
  }
  result += c2hex[port ~/ 4096] +
      c2hex[port % 4096 ~/ 256] +
      c2hex[port % 256 ~/ 16] +
      c2hex[port % 16];
  return result;
}

String decodeServerKey(String code) {
  if (code.length != 12) return null;

  const c2hex = '0123456789abcdef';

  var result = '';
  for (var i = 0; i < 4; i++) {
    if (result.length > 0) {
      result += '.';
    }
    var hiByte = c2hex.indexOf(code[i * 2]);
    var loByte = c2hex.indexOf(code[i * 2 + 1]);
    if (hiByte < 0 || loByte < 0) return null;
    var ipsegVal = hiByte * 16 + loByte;
    result += '$ipsegVal';
  }

  var port = 0;
  for (var i = 0; i < 4; i++) {
    var byte = c2hex.indexOf(code[8 + i]);
    if (byte < 0) return null;
    port = port * 16 + byte;
  }
  result += ':$port';
  return result;
}

String getURLPrefix(Store<AppState> store) {
  // eg: C0A803AB0BB8 which means 192.168.3.172:3000
  String serverKey = store.state.setting.serverKey;
  if (serverKey == null || serverKey.length == 0) {
    return null;
  }
  return "http://" + decodeServerKey(serverKey);
}

bool handleNetworkSucc(Store<AppState> store) {
  store.dispatch(SettingServerReachableAction(reachable: true));
  return true;
}

bool handleNetworkError(Store<AppState> store, Exception e) {
  if (e is SocketException) {
    if (e.osError.errorCode == 61 /* Connection refused */ ||
        e.osError.errorCode == 60 /* Operation timed out */ ||
        e.osError.errorCode == 111 /* Connection refused */) {
      store.dispatch(SettingServerReachableAction(reachable: false));
      print(e.toString());
      return true;
    } else if (e.osError.errorCode == 50 /* Network is down */) {
      print(e.toString());
      return true;
    }
  }
  return false;
}
