//
//  QRCaptureViewController.swift
//  Runner
//
//  Created by Simon Ding on 2021-01-16.
//

import Foundation
import AVFoundation

protocol QRCaptureDelegate {
    func QRCaptureSucceed(code: String)
    func QRCaptureFailed()
}

class QRCaptureViewController : UIViewController, AVCapturePhotoCaptureDelegate {
    private var delegate : QRCaptureDelegate?;
    
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
    
    // fix: AVCapture rotate animation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { (_) in
            UIView.setAnimationsEnabled(true)
        }
        UIView.setAnimationsEnabled(false)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func setDelegate(delegate: QRCaptureDelegate?) {
        self.delegate = delegate
    }
    
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
    
    func setupUI() {
        view.addSubview(backButton)
        view.addSubview(switchButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        backButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
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
        cameraController.prepare(for: .qr) { err in
            if let err = err {
                debugPrint("Failed to start camera: \(err)")
            }
            do {
                try self.cameraController.displayPreview(on: self.view)
                self.cameraController.captureQRCode(completionHandler: { code, err in
                    if let code = code {
                        self.delegate?.QRCaptureSucceed(code: code)
                        return
                    }
                    
                    debugPrint("Couldn't capture code: \(err!)")
                    return
                })
            } catch {
                debugPrint("Failed to preview camera")
            }
        }
    }

    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.delegate?.QRCaptureFailed()
        }
    }
    
    @objc private func handleSwitch() {
        do {
            try self.cameraController.switchCamera()
        } catch {
            debugPrint("Failed to switch camera")
        }
    }
}
