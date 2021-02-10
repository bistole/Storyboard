import 'package:flutter/services.dart';

const BK_GET_DATAHOME = "BK:GET_DATA_HOME";
const BK_GET_CURRENT_IP = "BK:GET_CURRENT_IP";
const BK_SET_CURRENT_IP = "BK:SET_CURRENT_IP";
const BK_GET_SERVER_IPS = "BK:GET_SERVER_IPS";

class BackendChannel {
  // required
  MethodChannel _channel;
  BackendChannel(MethodChannel channel) {
    _channel = channel;
  }

  Future<String> getDataHome() async {
    final datahome = await _channel.invokeMethod<String>(BK_GET_DATAHOME);
    return datahome;
  }

  Future<String> getCurrentIp() async {
    final ip = await _channel.invokeMethod<String>(BK_GET_CURRENT_IP);
    return ip;
  }

  Future<void> setCurrentIp(String ip) async {
    await _channel.invokeMethod(BK_SET_CURRENT_IP, ip);
  }

  Future<Map<String, String>> getAvailableIps() async {
    final answer =
        await _channel.invokeMapMethod<String, String>(BK_GET_SERVER_IPS);
    return answer;
  }
}
