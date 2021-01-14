//
//  PhotoPreviewView.swift
//  Runner
//
//  Created by Simon Ding on 2021-01-13.
//

import Foundation

class PhotoPreviewView : UIView {
    
    lazy var photoImageView : UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        return button
    }()
    
    lazy var savePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        addSubview(cancelButton)
        addSubview(savePhotoButton)
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true;
        photoImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true;
        photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true;
        photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true;
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true;
        cancelButton.widthAnchor.constraint(equalToConstant: 80).isActive = true;
        cancelButton.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        cancelButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: 90).isActive = true

        savePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        savePhotoButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true;
        savePhotoButton.widthAnchor.constraint(equalToConstant: 80).isActive = true;
        savePhotoButton.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        savePhotoButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: -90).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
