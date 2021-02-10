//
//  BackendEvents.swift
//  Runner
//
//  Created by Simon Ding on 2021-02-10.
//

import Foundation
import Flutter

class BackendEvents : NSObject {
    let BACKENDS = "/BACKENDS"
    let BK_GET_DATAHOME = "BK:GET_DATA_HOME"
    
    weak var binaryMessager : FlutterBinaryMessenger?
    var methodChannel : FlutterMethodChannel?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.BK_GET_DATAHOME:
            let dir = getDataHome()
            result(dir)
            break
        default:
            result(FlutterMethodNotImplemented);
        }
    }
    
    func register(withBinaryMessager bm: FlutterBinaryMessenger) {
        // save binary messager
        binaryMessager = bm;

        // create a method channel
        let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + BACKENDS
        methodChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: binaryMessager!)
        methodChannel?.setMethodCallHandler(self.methodInvoked(call:result:));
    }
    
}
