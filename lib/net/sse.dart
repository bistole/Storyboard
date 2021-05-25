import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';

enum NetSSEStatus {
  NotLaunched,
  WrongServer,
  Connected,
  Disconnected,
}

typedef void NetSSEUpdateFunc();

const String actionKeepalive = "alive";
const String actionNotify = "notify";
const String actionWelcome = "welcome";
const String actionClose = "close";

const String notifyTypeNote = "note";
const String notifyTypePhoto = "photo";

class NetSSE {
  String _logTag = (NetSSE).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  http.Client Function() _getHttpClient;
  void setGetHttpClient(http.Client Function() getHttpClient) {
    _getHttpClient = getHttpClient;
  }

  http.Client _currentHttpClient;

  NetSSEStatus _status = NetSSEStatus.NotLaunched;
  NetSSEStatus getStatus() {
    return _status;
  }

  bool _running = false;
  Map<String, NetSSEUpdateFunc> _updateFuncs = {};

  void _changeStatus(Store<AppState> store, NetSSEStatus status) {
    if (_status != status) {
      if (_status == NetSSEStatus.Connected) {
        store.dispatch(SettingServerReachableAction(reachable: false));
      } else if (status == NetSSEStatus.Connected) {
        store.dispatch(SettingServerReachableAction(reachable: true));
      }
      _status = status;
    }
  }

  void registerUpdateFunc(String type, NetSSEUpdateFunc func) {
    _updateFuncs[type] = func;
  }

  void _callUpdateFuncByType(String type) {
    if (_updateFuncs[type] != null) {
      _updateFuncs[type]();
    }
  }

  void _callUpdateAllFuncs() {
    _updateFuncs.forEach((key, func) {
      func();
    });
  }

  Future<void> connect(Store<AppState> store) async {
    _logger.info(_logTag, "connect");
    if (!_running) {
      _running = true;
      _runLoop(store);
    }
  }

  void disconnect() {
    _logger.info(_logTag, "disconnect");
    if (_running) {
      _closeHTTP();
      _running = false;
    }
  }

  Future<void> reconnect(Store<AppState> store) async {
    _logger.info(_logTag, "reconnect");
    disconnect();
    await connect(store);
  }

  void _closeHTTP() {
    _logger.info(_logTag, "_closeHTTP");
    if (_currentHttpClient != null) {
      _currentHttpClient.close();
      _currentHttpClient = null;
    }
  }

  bool _parseEvent(String body) {
    Map<String, dynamic> object = jsonDecode(body);
    switch (object['action'] as String) {
      case actionNotify:
        _logger.debug(_logTag, "SSE Recv actionNotify");
        if (object['params'] is Map && object['params']['type'] is String) {
          _callUpdateFuncByType(object['params']['type']);
        }
        break;
      case actionWelcome:
        _logger.debug(_logTag, "SSE Recv actionWelcome");
        break;
      case actionKeepalive:
        _logger.debug(_logTag, "SSE Recv actionKeepalive");
        break;
      case actionClose:
        _logger.debug(_logTag, "SSE Recv actionClose");
        return false;
      default:
        _logger.warn(_logTag, "SSE Recv unknown: $body");
    }
    return true;
  }

  Future<bool> _recvEvent(Store<AppState> store) async {
    _logger.info(_logTag, "_recvEvent");
    try {
      String prefix = getURLPrefix(store);
      if (prefix == null) {
        _changeStatus(store, NetSSEStatus.NotLaunched);
        _logger.info(_logTag, "_recvEvent no server url");
        return false;
      }

      _currentHttpClient = _getHttpClient();
      final response = await _currentHttpClient
          .send(http.Request(
            "GET",
            Uri.parse(prefix + "/events"),
          )..headers[headerNameClientID] = getClientID(store))
          .timeout(Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw new Exception("Expect 200 Response Status");
      }

      // succ to connect, call fetch all
      _callUpdateAllFuncs();

      store.dispatch(SettingServerReachableAction(reachable: true));
      _logger.info(_logTag, "_recvEvent connect to server");

      Completer<bool> completer = Completer<bool>();
      response.stream.listen((value) {
        var str = String.fromCharCodes(value).trim();
        if (_parseEvent(str)) {
          _changeStatus(store, NetSSEStatus.Connected);
        } else {
          _logger.info(_logTag, "_recvEvent server ask for close");
          _closeHTTP();
          _changeStatus(store, NetSSEStatus.Disconnected);
          completer.complete(false);
        }
      }, onError: (Object err) {
        // server is down or disconnected.
        // ClientException: Connection closed while receiving data
        _logger.error(_logTag, "SSE http catch error: ${err.runtimeType} $err");
        _closeHTTP();
        _changeStatus(store, NetSSEStatus.Disconnected);
        completer.complete(false);
      }, onDone: () {
        _logger.warn(_logTag, "SSE Connection is terminated");
        _changeStatus(store, NetSSEStatus.Disconnected);
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }, cancelOnError: true);

      return completer.future;
    } on SocketException catch (_) {
      // exception: SocketException: OS Error: Connection refused, errno = 61, address = 192.168.3.135, port = 55223
      _changeStatus(store, NetSSEStatus.WrongServer);
    } on TimeoutException catch (_) {
      // exception: TimeoutException after 0:00:05.000000: Future not completed
      _changeStatus(store, NetSSEStatus.WrongServer);
    } catch (e) {
      _logger.error(_logTag, "SSE Catch unexpected exception: $e");
      _changeStatus(store, NetSSEStatus.WrongServer);
    }
    _closeHTTP();
    _logger.info(_logTag, "_recvEvent exit");
    return false;
  }

  Future<void> _runLoop(Store<AppState> store) async {
    _logger.info(_logTag, "_runLoop");
    while (_running) {
      await _recvEvent(store);
      await Future.delayed(Duration(seconds: 2));
    }
    _logger.info(_logTag, "_runLoop exit");
  }
}
