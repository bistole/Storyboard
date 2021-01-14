import 'dart:io' show Platform;

class DeviceManager {
  bool isMacOS() => Platform.isMacOS;
  bool isWindows() => Platform.isWindows;
  bool isLinux() => Platform.isLinux;

  bool isAndroid() => Platform.isAndroid;
  bool isIOS() => Platform.isIOS;

  bool isDesktop() => isMacOS() || isWindows() || isLinux();
  bool isMobile() => isAndroid() || isIOS();
}
