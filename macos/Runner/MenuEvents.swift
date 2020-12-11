//
//  MenuEvents.swift
//  Runner
//
//  Created by Simon Ding on 2020-12-10.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import FlutterMacOS

class MenuEvents : NSObject {

  let MENU_EVENTS = "/MENU_EVENTS";
  
  let MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO"
  let MENU_TIMER = "TIMER"

  weak var binaryMessager : FlutterBinaryMessenger?
  var methodChannel : FlutterMethodChannel?
    
  func register(withBinaryMessager bm: FlutterBinaryMessenger) {
    // save binary messager
    binaryMessager = bm;

    // create a method channel
    let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + MENU_EVENTS
    methodChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: binaryMessager!)
    
    // create schedule
    Timer.scheduledTimer(
      timeInterval: 5,
      target: self,
      selector: #selector(MenuEvents.timer),
      userInfo: nil,
      repeats: true);
  }
  
  @objc func timer() {
    methodChannel?.invokeMethod(MENU_TIMER, arguments: Date().description);
  }
    
  // deliever menu event to flutter
  @IBAction func importPhoto(sender: AnyObject) {
    methodChannel?.invokeMethod(MENU_IMPORT_PHOTO, arguments: nil)
  }
}
