//
//  UIDeviceOrientation+Extension.swift
//  Runner
//
//  Created by Simon Ding on 2021-02-08.
//

import Foundation

extension UIDeviceOrientation {
    func UIImageOrientation(camera: CameraControllerPosition) -> UIImage.Orientation {
        switch self {
        case .portrait, .faceUp:
            return camera == .front ? .leftMirrored : .right
        case .portraitUpsideDown, .faceDown:
            return camera == .front ? .rightMirrored : .left
        case .landscapeLeft:
            return camera == .front ? .downMirrored : .up
        case .landscapeRight:
            return camera == .front ? .upMirrored : .down
        case .unknown:
            return .up;
        default:
            return .up;
        }
    }
}
