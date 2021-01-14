//
//  Camera.swift
//  Runner
//
//  Created by Simon Ding on 2021-01-12.
//

import Foundation
import AVFoundation

protocol PhotoCaptureDelegate {
    func photoCaptureSucceed(image: UIImage)
    func photoCaptureFailed()
}

class PhotoCaptureViewController : UIViewController, AVCapturePhotoCaptureDelegate {
    private var delegate : PhotoCaptureDelegate?;
    
    private var cameraController : CameraController = TARGET_OS_SIMULATOR != 0 ? FakeCamerController() : RealCameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        openCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraController.layoutPreview(on: self.view)
    }
    
    func setDelegate(delegate: PhotoCaptureDelegate?) {
        self.delegate = delegate
    }
    
    lazy private var backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white;
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        return button
    }()
    
    lazy private var switchButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.addTarget(self, action: #selector(handleSwitch), for: .touchUpInside)
        button.tintColor = .white;
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        return button
    }()
    
    lazy private var takePhotoButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle"), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        button.tintColor = .white;
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        return button
    }()
    
    func setupUI() {
        view.addSubview(backButton)
        view.addSubview(takePhotoButton)
        view.addSubview(switchButton)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        backButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        takePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        takePhotoButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        takePhotoButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.centerYAnchor.constraint(equalTo: takePhotoButton.centerYAnchor).isActive = true
        switchButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        switchButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        switchButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.startSession()
            break;
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.startSession()
                    }
                } else {
                    self.handleDismiss()
                }
            }
            break
        case .denied:
            // TODO:
            self.handleDismiss()
            break
        case .restricted:
            // TODO:
            self.handleDismiss()
            break
        default:
            self.handleDismiss()
        }
    }
        
    func startSession() {
        cameraController.prepare { err in
            if let err = err {
                debugPrint("Failed to start camera: \(err)")
            }
            do {
                try self.cameraController.displayPreview(on: self.view)
            } catch {
                debugPrint("Failed to preview camera")
            }
        }
    }

    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.delegate?.photoCaptureFailed()
        }
    }
    
    @objc private func handleSwitch() {
        do {
            try self.cameraController.switchCamera()
        } catch {
            debugPrint("Failed to switch camera")
        }
    }
    
    var photoPreviewView: PhotoPreviewView?

    @objc func handleTakePhoto() {
        self.cameraController.captureImage() { image, err in
            if let image = image {
                let previewView = PhotoPreviewView(frame: self.view.frame)
                previewView.photoImageView.image = image
                previewView.cancelButton.addTarget(self, action: #selector(self.handleCancelPreview), for: .touchUpInside)
                previewView.savePhotoButton.addTarget(self, action: #selector(self.handleSavePhoto), for: .touchUpInside)
                self.view.addSubview(previewView);
                
                self.photoPreviewView = previewView
                return
            }
            
            debugPrint("Couldn't capture image: \(err!)")
            return
        }
    }
    
    @objc func handleCancelPreview() {
        DispatchQueue.main.async {
            self.photoPreviewView?.removeFromSuperview()
            self.photoPreviewView = nil
        }
    }
    
    @objc func handleSavePhoto() {
        DispatchQueue.main.async {
            if let image = self.photoPreviewView?.photoImageView.image {
                self.delegate?.photoCaptureSucceed(image: image)
                return
            }
            self.delegate?.photoCaptureFailed()
        }
    }
}
