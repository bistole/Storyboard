import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';

class NetAuth {
  http.Client _httpClient;
  void setHttpClient(http.Client httpClient) {
    _httpClient = httpClient;
  }

  Future<bool> netPing(Store<AppState> store) async {
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) return false;

      final response =
          await _httpClient.get(prefix + "/ping").timeout(Duration(seconds: 1));
      if (response.statusCode == 200) {
        Map<String, dynamic> object = jsonDecode(response.body);
        if (object['pong'] == true) {
          handleNetworkSucc(store);
          return true;
        }
      }
    } on TimeoutException catch (_) {
      print("netPing timeout");
      store.dispatch(SettingServerReachableAction(reachable: false));
    } catch (e) {
      handleNetworkError(store, e);
      print("netPing failed: $e");
    }
    return false;
  }
}
