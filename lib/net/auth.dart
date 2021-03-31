import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';

class NetAuth {
  String _logTag = (NetAuth).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  Future<bool> netPing(Store<AppState> store) async {
    _logger.info(_logTag, "netPing");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      final response =
          await _httpClient.get(prefix + "/ping").timeout(Duration(seconds: 1));
      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['pong'] == true) {
          _logger.info(_logTag, "netPing succ");
          handleNetworkSucc(store);
          return true;
        }
      }
    } on TimeoutException catch (_) {
      _logger.info(_logTag, "netPing timeout");
      store.dispatch(SettingServerReachableAction(reachable: false));
    } catch (e) {
      if (!handleNetworkError(store, e)) {
        _logger.warn(_logTag, "netPing failed: $e");
      }
    }
    return false;
  }
}
