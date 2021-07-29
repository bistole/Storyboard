//
//  Commands.swift
//  Runner
//
//  Created by Simon Ding on 2020-12-10.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import Flutter

protocol CommandDelegate {
    func getNavigationController() -> UINavigationController;
}

class Commands : NSObject {
    let groupIdentifier = "group.com.laterhorse.storyboard.ios"
    let groupShareKey = "shareFromExtension"
    
    enum RedirectType {
        case media
        case text
    }
    
    enum SharedMediaType: Int, Codable {
        case image
    }
    
    class SharedMediaFile : Codable {
        var path: String;
        var type: SharedMediaType
        
        init(path: String, type: SharedMediaType) {
            self.path = path;
            self.type = type;
        }
        
        func toString() -> String {
            return "[SharedMediaFile]\n\tpath: \(self.path)\n\t\(self.type)"
        }
    }
    
    let COMMANDS = "/COMMANDS";
    let CMD_READY = "CMD:READY";
    let CMD_OPEN_DIALOG = "CMD:OPEN_DIALOG";
    let CMD_TAKE_PHOTO = "CMD:TAKE_PHOTO";
    let CMD_IMPORT_PHOTO = "CMD:IMPORT_PHOTO";
    let CMD_SHARE_OUT_PHOTO = "CMD:SHARE_OUT_PHOTO";
    let CMD_SHARE_OUT_TEXT = "CMD:SHARE_OUT_TEXT";
    let CMD_TAKE_QRCODE = "CMD:TAKE_QRCODE";
    
    let CMD_SHARE_IN_PHOTO = "CMD:SHARE_IN_PHOTO";
    let CMD_SHARE_IN_TEXT = "CMD:SHARE_IN_TEXT";

    var delegate: CommandDelegate?
    
    var methodChannel : FlutterMethodChannel?
    var result: FlutterResult?
    
    var channelIsReady: Bool = false
    var bufferShareInPhoto: UIImage?
    var bufferShareInText: String?
    
    func methodInvoked(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        NSLog(call.method);
        switch(call.method) {
        case self.CMD_READY:
            result(nil)
            if (!channelIsReady) {
                channelIsReady = true
                if let text = bufferShareInText {
                    shareInText(text: text)
                    bufferShareInText = nil
                } else if let photo = bufferShareInPhoto {
                    shareInPhoto(photo: photo)
                    bufferShareInPhoto = nil
                }
            }
            break;
        case self.CMD_TAKE_PHOTO:
            self.result = result
            DispatchQueue.main.async {
                let naviVC = self.delegate!.getNavigationController()
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

            let naviVC = self.delegate!.getNavigationController()
            naviVC.present(picker, animated: true, completion: nil)
            break;
        case self.CMD_SHARE_OUT_PHOTO:
            self.result = result
            // name, mime, path
            let args = call.arguments as! [String]
            guard args.count == 3 else { return }
            let url = URL(fileURLWithPath: args[2])
            let image = UIImage(contentsOfFile: url.path)!
            let naviVC = self.delegate!.getNavigationController()
            let ctrl = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            ctrl.popoverPresentationController?.sourceView = naviVC.view
            ctrl.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            naviVC.present(ctrl, animated: true, completion: nil)
            break;
        case self.CMD_SHARE_OUT_TEXT:
            self.result = result

            let text = call.arguments as! String
            
            let naviVC = self.delegate!.getNavigationController()
            let ctrl = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            ctrl.popoverPresentationController?.sourceView = naviVC.view
            ctrl.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            naviVC.present(ctrl, animated: true, completion: nil)
            break;
        case self.CMD_TAKE_QRCODE:
            self.result = result
            DispatchQueue.main.async {
                let naviVC = self.delegate!.getNavigationController()
                let QRCaptureVC = QRCaptureViewController()
                QRCaptureVC.setDelegate(delegate: self)
                naviVC.pushViewController(QRCaptureVC, animated: true)
            }
        default:
            result(FlutterMethodNotImplemented);
        }
    }

    func register(delegate: CommandDelegate, withBinaryMessager bm: FlutterBinaryMessenger) {
        self.delegate = delegate

        // create a method channel
        let channelName = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String) + COMMANDS
        methodChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: bm)
        methodChannel?.setMethodCallHandler(self.methodInvoked(call:result:));
    }
    
    func shareInText(text: String) {
        NSLog("shareInText: \(text)")
        if !channelIsReady {
            bufferShareInText = text
            return
        }
        methodChannel?.invokeMethod(self.CMD_SHARE_IN_TEXT, arguments: text)
    }
    
    func shareInPhoto(photo: UIImage) {
        NSLog("shareInPhoto: \(photo)")
        if !channelIsReady {
            bufferShareInPhoto = photo
            return
        }
        
        saveImageAndReturn(image: photo) { path in
            methodChannel?.invokeMethod(self.CMD_SHARE_IN_PHOTO, arguments: path)
        }
        
    }
    
    func shareFromExtension(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        var key: String? = nil
        var type: String? = nil
        if let queries = components?.queryItems {
            for (_, item) in queries.enumerated() {
                if item.name == "key" {
                    key = item.value
                } else if item.name == "type" {
                    type = item.value
                }
            }
        }
        guard key == self.groupShareKey else { return }
        
        let userDefaults = UserDefaults(suiteName: self.groupIdentifier)
        if type == "media" {
            if let data = userDefaults?.data(forKey: self.groupShareKey) {
                do {
                    let files = try JSONDecoder().decode([SharedMediaFile].self, from: data)
                    guard files.count > 0 else { return }
                    
                    let file = files[0]
                    if (file.type == .image) {
                        let url = URL(string: file.path)!
                        let data = try Data(contentsOf: url)
                        let photo = UIImage(data: data)!
                        shareInPhoto(photo: photo)
                    }
                } catch {
                    NSLog("error parse ud: \(error)")
                }
            }
        } else if type == "text" {
            if let text = userDefaults?.stringArray(forKey: self.groupShareKey) {
                guard text.count > 0 else { return }
                shareInText(text: text.joined(separator: "\n"))
            }
        }
    }
    
    func saveImageAndReturn(image : UIImage, completion: (_ path: String) -> Void) {
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
                completion(filename.path)
            }
        } catch {
            return
        }
    }
}

extension Commands : PhotoCaptureDelegate {
    func photoCaptureFailed() {
        let naviVC = self.delegate!.getNavigationController()
        naviVC.popViewController(animated: true)
    }
    
    func photoCaptureSucceed(image: UIImage) {
        let naviVC = self.delegate!.getNavigationController()
        naviVC.popViewController(animated: true)
        saveImageAndReturn(image: image) { path in
            result?(path)
        }
    }
}

extension Commands : QRCaptureDelegate {
    func QRCaptureFailed() {
        let naviVC = self.delegate!.getNavigationController()
        naviVC.popViewController(animated: true)
    }
    
    func QRCaptureSucceed(code: String) {
        let naviVC = self.delegate!.getNavigationController()
        naviVC.popViewController(animated: true)
        result?(code)
    }
}

extension Commands : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let naviVC = self.delegate!.getNavigationController()
        naviVC.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let naviVC = self.delegate!.getNavigationController()
        naviVC.dismiss(animated: true, completion:{ [self] in
            self.saveImageAndReturn(image: image) { path in
                result?(path)
            }
        })
    }
}
