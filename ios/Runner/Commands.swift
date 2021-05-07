//
//  Commands.swift
//  Runner
//
//  Created by Simon Ding on 2020-12-10.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import Flutter

class Commands : NSObject {
    let COMMANDS = "/COMMANDS";
    let CMD_OPEN_DIALOG = "CMD:OPEN_DIALOG";
    let CMD_TAKE_PHOTO = "CMD:TAKE_PHOTO";
    let CMD_IMPORT_PHOTO = "CMD:IMPORT_PHOTO";
    let CMD_TAKE_QRCODE = "CMD:TAKE_QRCODE";
    
    var delegate: FlutterAppDelegate?
    var methodChannel : FlutterMethodChannel?
    var result: FlutterResult?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.CMD_TAKE_PHOTO:
            self.result = result
            DispatchQueue.main.async {
                let naviVC = self.delegate?.window?.rootViewController as! UINavigationController
                let photoCaptureVC = PhotoCaptureViewController()
                photoCaptureVC.setDelegate(delegate: self)
                naviVC.pushViewController(photoCaptureVC, animated: true)
            }
            break;
        case self.CMD_IMPORT_PHOTO:
            self.result = result
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.mediaTypes = ["public.image"]
            picker.sourceType = .photoLibrary

            let naviVC = self.delegate?.window?.rootViewController as! UINavigationController
            naviVC.present(picker, animated: true, completion: nil)
            break;
        case self.CMD_TAKE_QRCODE:
            self.result = result
            DispatchQueue.main.async {
                let naviVC = self.delegate?.window?.rootViewController as! UINavigationController
                let QRCaptureVC = QRCaptureViewController()
                QRCaptureVC.setDelegate(delegate: self)
                naviVC.pushViewController(QRCaptureVC, animated: true)
            }
        default:
            result(FlutterMethodNotImplemented);
        }
    }

    func register(delegate: FlutterAppDelegate, withBinaryMessager bm: FlutterBinaryMessenger) {
        self.delegate = delegate

        // create a method channel
        let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + COMMANDS
        methodChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: bm)
        methodChannel?.setMethodCallHandler(self.methodInvoked(call:result:));
    }
    
    func saveImageAndReturn(image : UIImage) {
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
                result?(filename.path)
            }
        } catch {
            return
        }
    }
}

extension Commands : PhotoCaptureDelegate {
    func photoCaptureFailed() {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.popViewController(animated: true)
    }
    
    func photoCaptureSucceed(image: UIImage) {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.popViewController(animated: true)
        saveImageAndReturn(image: image)
    }
}

extension Commands : QRCaptureDelegate {
    func QRCaptureFailed() {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.popViewController(animated: true)
    }
    
    func QRCaptureSucceed(code: String) {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.popViewController(animated: true)
        result?(code)
    }
}

extension Commands : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let naviVC = delegate?.window?.rootViewController as! UINavigationController
        naviVC.dismiss(animated: true, completion:{ [self] in
            self.saveImageAndReturn(image: image)
        })
    }
}
