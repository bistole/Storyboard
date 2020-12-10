//
//  MenuEvents.swift
//  Runner
//
//  Created by Simon Ding on 2020-12-10.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import FlutterMacOS

class MenuEvents : NSObject, FlutterStreamHandler {
    
  let MENU_EVENTS = "/MENU_EVENTS";
  
  let MENU_IMPORT_PHOTO = "MENU_EVENTS:IMPORT_PHOTO"

  weak var binaryMessager : FlutterBinaryMessenger?
  var eventsSink : FlutterEventSink? = nil
    
  func register(withBinaryMessager bm: FlutterBinaryMessenger) {
    // save binary messager
    binaryMessager = bm;

    // create a event channel
    let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + MENU_EVENTS
    let eventChannel = FlutterEventChannel.init(name: channelName, binaryMessenger: binaryMessager!)
    eventChannel.setStreamHandler(self)

    // create schedule
    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MenuEvents.timer), userInfo: nil, repeats: true);
  }
  
  @objc func timer() {
    if eventsSink != nil {
      eventsSink!("Hello: " + Date().description);
    }
  }
    
  // flutter start to listen this event
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    // callback func to send out event
    eventsSink = events
    return nil
  }
  
  // flutter cancelled this event
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventsSink = nil;
    return nil
  }
    
  // deliever menu event to flutter
  @IBAction func importPhoto(sender: AnyObject) {
    if eventsSink != nil {
      eventsSink!(MENU_IMPORT_PHOTO);
    }
  }
}
