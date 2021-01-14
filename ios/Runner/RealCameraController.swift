//
//  RealCameraController.swift
//  Runner
//
//  Created by Simon Ding on 2021-01-13.
//

import Foundation
import AVFoundation

class RealCameraController : NSObject, CameraController {
    private var captureSession : AVCaptureSession?
    private var cameraPosition : CameraControllerPosition?
    private var frontCamera: AVCaptureDevice?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var rearCamera: AVCaptureDevice?
    private var rearCameraInput: AVCaptureDeviceInput?
    
    private var photoOutput : AVCapturePhotoOutput?
    private var photoOutputLayer: AVCaptureVideoPreviewLayer?
    private var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?

    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            print("captureSession: \(self.captureSession!)")
        }
        
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            let cameras = session.devices
            
            if cameras.isEmpty {
                throw CameraControllerError.noCamerasAvailable
            }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                } else if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                self.cameraPosition = .front
            } else if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                self.cameraPosition = .rear
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray(
                [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
                completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
        }
        
        func startSession() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                try startSession()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        self.photoOutputLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let photoOutputLayer = self.photoOutputLayer {
            print("cameraLayer: \(photoOutputLayer)")
            photoOutputLayer.frame = view.frame
            photoOutputLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(photoOutputLayer)
        }
    }
    
    func layoutPreview(on view: UIView) {
        if let photoOutputLayer = self.photoOutputLayer {
            photoOutputLayer.frame = view.frame
        }
    }
    
    func captureImage(completionHandler: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            completionHandler(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        self.photoCaptureCompletionBlock = completionHandler
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func switchCamera() throws {
        guard let currentPosition = self.cameraPosition,
            let captureSession = self.captureSession,
            captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        func switchToFrontCamera() throws {
            guard let rearCameraInput = self.rearCameraInput else {
                throw CameraControllerError.invalidOperation
            }
            
            let inputs = captureSession.inputs as [AVCaptureInput]
            if !inputs.contains(rearCameraInput) {
                throw CameraControllerError.invalidOperation
            }
                
            if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                captureSession.removeInput(rearCameraInput)
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                }
                self.cameraPosition = .front
            }
        }
        
        func switchToRearCamera() throws {
            guard let frontCameraInput = self.frontCameraInput else {
                throw CameraControllerError.invalidOperation
            }
            
            let inputs = captureSession.inputs as [AVCaptureInput]
            if !inputs.contains(frontCameraInput) {
                throw CameraControllerError.invalidOperation
            }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                captureSession.removeInput(frontCameraInput)
                if captureSession.canAddInput(rearCameraInput!) {
                    captureSession.addInput(rearCameraInput!)
                }
                self.cameraPosition = .rear
            }
        }
        
        captureSession.beginConfiguration()
        
        switch cameraPosition {
        case .front:
            try switchToRearCamera()
            break;
        case .rear:
            try switchToFrontCamera()
            break;
        default:
            break;
        }
        
        captureSession.commitConfiguration()
    }
}

extension RealCameraController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
            return
        }
        
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image, nil)
        } else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

