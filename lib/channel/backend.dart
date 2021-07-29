import 'package:flutter/services.dart';
import 'package:storyboard/logger/logger.dart';

const BK_GET_DATAHOME = "BK:GET_DATA_HOME";
const BK_GET_CURRENT_IP = "BK:GET_CURRENT_IP";
const BK_SET_CURRENT_IP = "BK:SET_CURRENT_IP";
const BK_GET_SERVER_IPS = "BK:GET_SERVER_IPS";

class BackendChannel {
  String _logTag = (BackendChannel).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  // required
  MethodChannel _channel;
  BackendChannel(MethodChannel channel) {
    _channel = channel;
  }

  Future<String> getDataHome() async {
    final datahome = await _channel.invokeMethod<String>(BK_GET_DATAHOME);
    _logger.info(_logTag, "getDataHome: $datahome");
    return datahome;
  }

  Future<String> getCurrentIp() async {
    final ip = await _channel.invokeMethod<String>(BK_GET_CURRENT_IP);
    _logger.info(_logTag, "getCurrentIp: $ip");
    return ip;
  }

  Future<void> setCurrentIp(String ip) async {
    _logger.info(_logTag, "setCurrentIp: $ip");
    await _channel.invokeMethod(BK_SET_CURRENT_IP, ip);
  }

  Future<Map<String, String>> getAvailableIps() async {
    _logger.info(_logTag, "getAvailableIps");
    final answer =
        await _channel.invokeMapMethod<String, String>(BK_GET_SERVER_IPS);
    return answer;
  }
}
