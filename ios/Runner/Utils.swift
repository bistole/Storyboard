//
//  Utils.swift
//  Runner
//
//  Created by Simon Ding on 2021-02-10.
//

import Foundation

enum Error: Swift.Error {
    case missingKey, invalidValue
}

func getConfigureValue<T>(for key: String) throws -> T where T: LosslessStringConvertible {
    guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
        throw Error.missingKey;
    }
    
    switch object {
    case let value as T:
        return value
    case let string as String:
        guard let value = T(string) else { fallthrough }
        return value
    default:
        throw Error.invalidValue
    }
}

func getEnv() -> String {
    return try! getConfigureValue(for: "SB_ENV")
}

func getDataHome() -> String {
    let env = getEnv()
    let localPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
    let idComp = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String)
    let components = env != "" ? [localPath, idComp, env] : [localPath, idComp]
    let fullPath = NSString.path(withComponents: components)
    return fullPath
}
