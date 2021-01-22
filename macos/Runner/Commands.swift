//
//  Commands.swift
//  Runner
//
//  Created by Simon Ding on 2020-12-10.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import FlutterMacOS

class OpenDialog : NSObject {
    var rs : FlutterResult?
    func openFileDialog(title: String, fileTypes: String, result: @escaping FlutterResult) -> Void {
        let dialog = NSOpenPanel.init()
        dialog.title = title
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.canChooseFiles = true
        dialog.allowedFileTypes = fileTypes.components(separatedBy: ";")
        self.rs = result
        dialog.begin(completionHandler: {(response: NSApplication.ModalResponse) in
            if (response == .OK) {
                var answer : [String] = Array<String>.init();
                for url in dialog.urls {
                    answer.append(url.path)
                }
                self.rs?(answer)
            } else {
                self.rs?([])
            }
        })
    }    
}

class Commands : NSObject {
    let COMMANDS = "/COMMANDS";
    let CMD_OPEN_DIALOG = "CMD:OPEN_DIALOG";
    let CMD_GET_CURRENT_IP = "CMD:GET_CURRENT_IP"
    let CMD_SET_CURRENT_IP = "CMD:SET_CURRENT_IP"
    let CMD_GET_SERVER_IPS = "CMD:GET_SERVER_IPS"
    
    weak var binaryMessager : FlutterBinaryMessenger?
    var methodChannel : FlutterMethodChannel?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.CMD_OPEN_DIALOG:
            let dict = call.arguments as! Dictionary<String, String>;
            let dialog = OpenDialog()
            dialog.openFileDialog(
                title: dict["title"] ?? "Import Files",
                fileTypes: dict["types"] ?? "*",
                result: result)
            break
        case self.CMD_GET_CURRENT_IP:
            if let ipRaw = Backend_GetCurrentIP() {
                let ip = String(cString: ipRaw, encoding: String.Encoding.ascii);
                result(ip)
                free(ipRaw)
            }
            break
        case self.CMD_SET_CURRENT_IP:
            let ip : String = call.arguments as! String
            if let ipdata = (ip as NSString).utf8String {
                let ippchar = UnsafeMutablePointer<Int8>.init(mutating: ipdata)
                Backend_SetCurrentIP(ippchar)
            }
            result(true)
            break;
        case self.CMD_GET_SERVER_IPS:
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
        default:
            result(FlutterMethodNotImplemented);
        }
    }
    
    func register(withBinaryMessager bm: FlutterBinaryMessenger) {
        // save binary messager
        binaryMessager = bm;

        // create a method channel
        let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + COMMANDS
        methodChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: binaryMessager!)
        methodChannel?.setMethodCallHandler(self.methodInvoked(call:result:));
    }
}
