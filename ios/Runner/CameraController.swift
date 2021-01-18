//
//  CameraController.swift
//  Runner
//
//  Created by Simon Ding on 2021-01-13.
//

import Foundation

protocol CameraController {
    func prepare(for: CameraControllerTarget, completionHandler: @escaping (Error?) -> Void)
    
    func captureImage(completionHandler: @escaping (UIImage?, Error?) -> Void)
    
    func captureQRCode(completionHandler: @escaping (String?, Error?) -> Void)
    
    func displayPreview(on view: UIView) throws
    
    func layoutPreview(on view: UIView)
    
    func switchCamera() throws
}

enum CameraControllerTarget {
    case photo
    case qr
}

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

enum CameraControllerPosition {
    case front
    case rear
}
