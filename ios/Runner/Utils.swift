//
//  Utils.swift
//  Runner
//
//  Created by Simon Ding on 2021-02-10.
//

import Foundation

func getDataHome() -> String {
    let localPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
    let idComp = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String)
    let fullPath = NSString.path(withComponents: [localPath, idComp]);
    return fullPath;
}
