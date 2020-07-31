//
//  RoundIconButton.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class RoundIconButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
        setupProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpLayout() {
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),
            widthAnchor.constraint(equalToConstant: 30),
            
        ])
    }
    
    private func setupProperties() {
        //        backImageView.image = UIImage(named: "exit")
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }
    
    private func config(type: ButtonType, isActive: Bool) {
        self.backgroundColor = type.backgroundColor
        if let image = UIImage(named: type.iconName(isActive: true)) {
            self.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
}

extension RoundIconButton {
    enum ButtonType {
        case video
        case microphone
        case flipCamera
        case exit
        
        var backgroundColor: UIColor {
            switch self {
            case .video,
                 .microphone,
                 .flipCamera:
                return UIColor.gray
            case .exit:
                return UIColor.red
            }
        }
        
        func iconName(isActive: Bool = false) -> String {
            switch self {
            case .video:
                return isActive ? "camera_icon_active" : "camera_icon_not_active"
            case .microphone:
                return isActive ? "microphone_icon_active" : "microphone_icon_not_active"
            case .flipCamera:
                return isActive ? "flip_camera_icon_active" : "flip_camera_icon_not_active"
            case .exit:
                return "exit_icon"
                
            }
        }
    }
}
