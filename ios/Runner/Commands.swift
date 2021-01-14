//
//  Commands.swift
//  Runner
//
//  Created by Simon Ding on 2020-12-10.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import Flutter

class Commands : NSObject, PhotoCaptureDelegate {
    let COMMANDS = "/COMMANDS";
    let CMD_OPEN_DIALOG = "CMD:OPEN_DIALOG";
    
    var delegate: FlutterAppDelegate?
    var methodChannel : FlutterMethodChannel?
    var result: FlutterResult?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.CMD_OPEN_DIALOG:
            self.result = result
            DispatchQueue.main.async {
                let naviVC = self.delegate?.window?.rootViewController as! UINavigationController
                let photoCaptureVC = PhotoCaptureViewController()
                photoCaptureVC.setDelegate(delegate: self)
                naviVC.pushViewController(photoCaptureVC, animated: true)
            }
            break;
        default:
            result(FlutterMethodNotImplemented);
        }
    }
    
    func photoCaptureFailed() {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.popViewController(animated: true)
    }
    
    func photoCaptureSucceed(image: UIImage) {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.popViewController(animated: true)
        do {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US")
            df.dateFormat = "yyyyMMdd_HHmmss";
            let ts = df.string(from: Date())
            
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = dir.appendingPathComponent("JPEG_\(ts)_.jpeg")

            print("Write photo to: \(filename)");
            if let data = image.jpegData(compressionQuality: 1.0) {
                try data.write(to: filename)
                result?([filename.path])
            }
        } catch {
            return
        }
        
    }
    
    func register(delegate: FlutterAppDelegate, withBinaryMessager bm: FlutterBinaryMessenger) {
        self.delegate = delegate

        // create a method channel
        let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + COMMANDS
        methodChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: bm)
        methodChannel?.setMethodCallHandler(self.methodInvoked(call:result:));
    }
}
