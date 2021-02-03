import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/models/app.dart';

enum NetSSEStatus {
  NotLaunched,
  WrongServer,
  Connected,
  Disconnected,
}

class NetSSE {
  http.Client Function() _getHttpClient;
  void setGetHttpClient(http.Client Function() getHttpClient) {
    _getHttpClient = getHttpClient;
  }

  NetSSEStatus status = NetSSEStatus.NotLaunched;

  Future<void> connect(Store<AppState> store) async {
    while (true) {
      await netKeepalive(store);
      sleep(Duration(seconds: 2));
    }
  }

  Future<bool> netKeepalive(Store<AppState> store) async {
    print("netKeepalive");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) {
        status = NetSSEStatus.NotLaunched;
        return false;
      }

      final client = _getHttpClient();
      final response = await client
          .send(http.Request(
            "GET",
            Uri.parse(prefix + "/events"),
          ))
          .timeout(Duration(seconds: 5));

      if (response.statusCode != 200) {
        status = NetSSEStatus.WrongServer;
        return false;
      }

      Completer<bool> completer = Completer<bool>();
      response.stream.listen((value) {
        var str = String.fromCharCodes(value).trim();
        print("recv: $str");
        status = NetSSEStatus.Connected;
      }, onError: (Object err) {
        // server is down or disconnected.
        // ClientException: Connection closed while receiving data
        print("error: ${err.runtimeType} $err");
        client.close();
        status = NetSSEStatus.Disconnected;
        completer.complete(false);
      }, onDone: () {
        print("Connection is terminated");
        status = NetSSEStatus.Disconnected;
        completer.complete(false);
      }, cancelOnError: true);

      return completer.future;
    } catch (e) {
      // exception: SocketException: OS Error: Connection refused, errno = 61, address = 192.168.3.135, port = 55223
      // exception: TimeoutException after 0:00:05.000000: Future not completed
      print("exception: $e");
      status = NetSSEStatus.WrongServer;
      return false;
    }
  }
}
