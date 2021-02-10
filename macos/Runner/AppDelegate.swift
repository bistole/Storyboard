import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationWillFinishLaunching(_ notification: Notification) {
    NSLog("Starting Backend...");
    
    let fullPath = getDataHome()
    if let iddata = (fullPath as NSString).utf8String {
        let idpchar = UnsafeMutablePointer<Int8>.init(mutating: iddata)
        Backend_Start(idpchar);
    }

    NSLog("Backend Started");
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
