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
    
    func saveFileDialog(title: String, fileURL: URL, result: @escaping FlutterResult) -> Void {
        let dialog = NSSavePanel.init()
        dialog.title = title
        dialog.canCreateDirectories = true
        dialog.canSelectHiddenExtension = true
        dialog.nameFieldStringValue = fileURL.lastPathComponent
        dialog.allowedFileTypes = ["jpeg", "jpg", "png", "gif"]
        dialog.allowsOtherFileTypes = true
        self.rs = result
        dialog.begin(completionHandler: {(response: NSApplication.ModalResponse) in
            if (response == .OK) {
                guard let url = dialog.url else {
                    self.rs?(false)
                    return
                }
                do {
                    if FileManager.default.fileExists(atPath: url.path) {
                        print("try remove")
                        try FileManager.default.removeItem(atPath: url.path)
                    }
                    print("copy")
                    try FileManager.default.copyItem(atPath: fileURL.path,
                                                     toPath: url.path)
                    print("change date")
                    try FileManager.default.setAttributes(
                        [FileAttributeKey.modificationDate: NSDate()],
                        ofItemAtPath: url.path
                    )
                } catch {
                    print(error)
                }
                self.rs?(true)
            } else {
                self.rs?(false)
            }
        })
    }
}

class Commands : NSObject {
    let COMMANDS = "/COMMANDS";
    let CMD_OPEN_DIALOG = "CMD:OPEN_DIALOG";
    let CMD_SHARE_OUT_PHOTO = "CMD:SHARE_OUT_PHOTO";
    let CMD_SHARE_OUT_TEXT = "CMD:SHARE_OUT_TEXT";
    
    weak var binaryMessager : FlutterBinaryMessenger?
    var methodChannel : FlutterMethodChannel?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.CMD_OPEN_DIALOG:
            let dict = call.arguments as! Dictionary<String, String>
            let dialog = OpenDialog()
            dialog.openFileDialog(
                title: dict["title"] ?? "Import Files",
                fileTypes: dict["types"] ?? "*",
                result: result)
            break
        case self.CMD_SHARE_OUT_PHOTO:
            let filename = call.arguments as! String
            let fileURL = URL(fileURLWithPath: filename)
            let dialog = OpenDialog()
            dialog.saveFileDialog(
                title: "Export Photo",
                fileURL: fileURL,
                result: result)
            break
        case self.CMD_SHARE_OUT_TEXT:
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
