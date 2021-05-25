//
//  ShareViewController.swift
//  Share
//
//  Created by Simon Ding on 2021-05-16.
//

import UIKit
import Foundation
import Social
import MobileCoreServices

class LoadItemError : Error {}

class ShareViewController: SLComposeServiceViewController {
    let groupIdentifier = "group.com.laterhorse.storyboard.ios"
    let groupShareKey = "shareFromExtension"
    let shareSchema = "StoryboardShare"
    
    let imageContentType = kUTTypeImage as String
    let textContentType = kUTTypeText as String
    let urlContentType = kUTTypeURL as String
    
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
    
    var sharedText : [String] = []
    var sharedMedia : [SharedMediaFile] = []

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let content = extensionContext?.inputItems[0] as? NSExtensionItem {
            processContent(content: content)
        }
    }

    override func didSelectPost() {
        print("didSelectPost")
    }

    override func configurationItems() -> [Any]! {
        return []
    }
    
    private func processContent(content: NSExtensionItem) {
        NSLog("processContent")
        if let attachments = content.attachments {
            for (index, attachment) in (attachments).enumerated() {
                if attachment.hasItemConformingToTypeIdentifier(imageContentType) {
                    processAsImage(content: content, attachment: attachment, index: index)
                } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                    processAsText(content: content, attachment: attachment, index: index)
                } else if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                    processAsURL(content: content, attachment: attachment, index: index)
                }
            }
        }
    }
    
    private func processAsText(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: textContentType, options: nil) { [weak self] data, error in
            if error == nil, let item = data as? String, let this = self {
                this.sharedText.append(item)
                if (index == (content.attachments?.count)! - 1) {
                    NSLog("processAsText Done: %@", this.sharedText)
                    let userDefaults = UserDefaults(suiteName: this.groupIdentifier)
                    userDefaults?.set(this.sharedText, forKey: this.groupShareKey)
                    userDefaults?.synchronize()
                    self?.redirectToHostApp(type: .text)
                }
            } else {
                self?.dismissWithError(error ?? LoadItemError())
            }
        }
    }
    
    private func processAsURL(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: urlContentType, options: nil) { [weak self] data, error in
            if error == nil, let item = data as? URL, let this = self {
                this.sharedText.append(item.absoluteString)
                if (index == (content.attachments?.count)! - 1) {
                    NSLog("processAsText Done: %@", this.sharedText)
                    let userDefaults = UserDefaults(suiteName: this.groupIdentifier)
                    userDefaults?.set(this.sharedText, forKey: this.groupShareKey)
                    userDefaults?.synchronize()
                    self?.redirectToHostApp(type: .text)
                }
            } else {
                self?.dismissWithError(error ?? LoadItemError())
            }
        }
    }
    
    private func processAsImage(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: imageContentType, options: nil) {[weak self] data, error in
            if error == nil, let item = data as? URL, let this = self {
                let ext = this.getExtension(from: item)
                let newName = UUID().uuidString
                NSLog("oldPath: %@", item.absoluteString)
                let newPath: URL = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: this.groupIdentifier)!
                    .appendingPathComponent("\(newName).\(ext)")
                NSLog("newPath: %@", newPath.absoluteString)
                let copied = this.copyFile(from: item, to: newPath)
                if (copied) {
                    let f = SharedMediaFile(path: newPath.absoluteString, type: .image)
                    NSLog("f: %@", f.toString())
                    this.sharedMedia.append(f)
                }
                
                if (index == (content.attachments?.count)! - 1) {
                    NSLog("processAsImage Done: %@", this.sharedMedia)
                    let userDefaults = UserDefaults(suiteName: this.groupIdentifier)
                    userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.groupShareKey)
                    userDefaults?.synchronize()
                    self?.redirectToHostApp(type: .media)
                }
            } else {
                self?.dismissWithError(error ?? LoadItemError())
            }
        }
    }
    
    private func dismissWithError(_ error: Error) {
        NSLog("[ERROR] Error: \(error)")
        let alert = UIAlertController(
            title: "Unable to share",
            message: "Message: \(error)",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func redirectToHostApp(type: RedirectType) {
        let url = URL(string: "\(shareSchema)://sharing?key=\(groupShareKey)&type=\(type)")
        NSLog("redirectToHostApp: %@", url?.absoluteString ?? "missing")

        let selectorOpenURL = sel_registerName("openURL:")
        let selectorCanOpenURL = sel_registerName("canOpenURL:")
        var responder = self as UIResponder?
        while (responder != nil) {
            if (responder?.responds(to: selectorCanOpenURL))! && (responder?.responds(to: selectorOpenURL))! {
                let _ = responder?.perform(selectorCanOpenURL, with: url)
                let _ = responder?.perform(selectorOpenURL, with: url)
            }
            responder = responder?.next
        }
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func getExtension(from url: URL) -> String {
        let parts = url.lastPathComponent.components(separatedBy: ".")
        var ex = parts.count > 1 ? parts[parts.count - 1] : nil
        
        if ex == nil {
            ex = "png"
        }
        return ex ?? "Unknown"
    }
        
    private func copyFile(from src: URL, to dest: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: src, to: dest)
        } catch (let error) {
            print("can not copy file from \(src) to \(dest): \(error)")
            return false
        }
        return true
    }
    
    private func toData(data: [SharedMediaFile]) -> Data {
        let encodedData = try? JSONEncoder().encode(data)
        return encodedData!
    }
    
}
