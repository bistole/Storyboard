import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:storyboard/logger/logger.dart';

class ChannelManager {
  String _LOG_TAG = (ChannelManager).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  Future<MethodChannel> createChannel(String name) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    String channelName = info.packageName + name;
    _logger.debug(_LOG_TAG, "createChannel: $channelName");
    return MethodChannel(channelName);
  }
}
