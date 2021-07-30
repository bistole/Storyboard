//
//  BackendEvents.swift
//  Runner
//
//  Created by Simon Ding on 2021-02-10.
//  Copyright © 2021 The Flutter Authors. All rights reserved.
//

import Foundation
import FlutterMacOS

class BackendEvents : NSObject {
    let BACKENDS = "/BACKENDS"
    let BK_GET_DATAHOME = "BK:GET_DATA_HOME"
    let BK_GET_CURRENT_IP = "BK:GET_CURRENT_IP"
    let BK_SET_CURRENT_IP = "BK:SET_CURRENT_IP"
    let BK_GET_SERVER_IPS = "BK:GET_SERVER_IPS"
    
    weak var binaryMessager : FlutterBinaryMessenger?
    var methodChannel : FlutterMethodChannel?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.BK_GET_DATAHOME:
            if let dirRaw = Backend_GetDataFolder() {
                let dir = String(cString: dirRaw, encoding: String.Encoding.ascii);
                result(dir)
                free(dirRaw)
            }
            break
        case self.BK_GET_CURRENT_IP:
            if let ipRaw = Backend_GetCurrentIP() {
                let ip = String(cString: ipRaw, encoding: String.Encoding.ascii);
                result(ip)
                free(ipRaw)
            }
            break
        case self.BK_SET_CURRENT_IP:
            let ip : String = call.arguments as! String
            if let ipdata = (ip as NSString).utf8String {
                let ippchar = UnsafeMutablePointer<Int8>.init(mutating: ipdata)
                Backend_SetCurrentIP(ippchar)
            }
            result(true)
            break;
        case self.BK_GET_SERVER_IPS:
            do {
                if let ipsRaw = Backend_GetAvailableIPs() {
                    let ipsStr = String(cString: ipsRaw, encoding: String.Encoding.ascii)
                    if let ipsData = ipsStr?.data(using: .utf8) {
                        let ipsJson = try JSONSerialization.jsonObject(with: ipsData, options: [])
                        result(ipsJson)
                    }
                }
            } catch {
                result({})
            }
            break;
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
