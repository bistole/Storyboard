import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

class ChannelManager {
  Future<MethodChannel> createChannel(String name) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    String channelName = info.packageName + name;
    return MethodChannel(channelName);
  }
}
