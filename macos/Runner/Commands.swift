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
