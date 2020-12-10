import 'package:package_info/package_info.dart';
import 'package:storyboard/net/config.dart';

const MENU_EVENTS = "/MENU_EVENTS";

var menuImportEvent;

void bindMenuEvents() {
  PackageInfo.fromPlatform().then((info) {
    menuImportEvent = enableSubscription(
      info.packageName + MENU_EVENTS,
      (evt) {
        print('receive event: $evt');
      },
    );
  });
}

void unbindMenuEvents() {
  if (menuImportEvent) {
    disableSubscription(menuImportEvent);
    menuImportEvent = null;
  }
}
