//
//  FakeCameraController.swift
//  Runner
//
//  Created by Simon Ding on 2021-01-13.
//

import Foundation

class FakeCamerController : NSObject, CameraController {
    var type: CameraControllerTarget?
    var previewLayer = CALayer()
    var rearImage = UIImage(named: "RearCamera")!
    var frontImage = UIImage(named: "FrontCamera")!
    var cameraPosition = CameraControllerPosition.front
    
    func prepare(for type: CameraControllerTarget, completionHandler: @escaping (Error?) -> Void) {
        setPreviewFrame(image: frontImage)
        self.type = type;
        completionHandler(nil)
    }
    
    func captureImage(completionHandler: @escaping (UIImage?, Error?) -> Void) {
        if self.type != .photo {
            return completionHandler(nil, CameraControllerError.invalidOperation)
        }
        if self.cameraPosition == CameraControllerPosition.front {
            return completionHandler(frontImage, nil);
        } else {
            return completionHandler(rearImage, nil);
        }
    }
    
    func captureQRCode(completionHandler: @escaping (String?, Error?) -> Void) {
        if self.type != .qr {
            return completionHandler(nil, CameraControllerError.invalidOperation)
        }
        if cameraPosition == .front {
            return completionHandler("THIS IS MOCK CODE", nil)
        } else {
            return completionHandler("THIS IS REAR MOCK CODE", nil)
        }
    }
    
    func displayPreview(on view: UIView) throws {
        self.previewLayer.frame = view.bounds
        view.layer.insertSublayer(self.previewLayer, at: 0)
    }
    
    func layoutPreview(on view: UIView) {
        self.previewLayer.frame = view.bounds
    }
    
    func switchCamera() throws {
        if self.cameraPosition == CameraControllerPosition.rear {
            self.cameraPosition = .front
            setPreviewFrame(image: frontImage)
        } else {
            self.cameraPosition = .rear
            setPreviewFrame(image: rearImage)
        }
    }
    
    private func setPreviewFrame(image: UIImage) {
        previewLayer.contents = image.cgImage
        previewLayer.contentsGravity = .resizeAspectFill
    }
}
