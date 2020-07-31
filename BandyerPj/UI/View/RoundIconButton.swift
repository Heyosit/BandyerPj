//
//  RoundIconButton.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class RoundIconButton: UIButton {
    
    private var type: ButtonType = .video
    
    convenience init(type: ButtonType) {
        self.init()
        self.type = type
        setupButtonStyle()
    }
    
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
            heightAnchor.constraint(equalToConstant: 70),
            widthAnchor.constraint(equalToConstant: 70),
            
        ])
    }
    
    private func setupProperties() {
        //        backImageView.image = UIImage(named: "exit")
        self.layer.cornerRadius = 35
        self.layer.masksToBounds = true
        
    }
    
    private func setupButtonStyle() {
        self.backgroundColor = type.backgroundColor
        if let image = UIImage(named: type.iconName(isActive: true)) {
            self.setImage(image.withRenderingMode(.automatic), for: .normal)
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
                return UIColor.darkGray
            case .exit:
                return UIColor.red
            }
        }
        
        func iconName(isActive: Bool = false) -> String {
            switch self {
            case .video:
                return isActive ? "􀍊" : "􀍎"
            case .microphone:
                return isActive ? "􀊱" : "􀊳"
            case .flipCamera:
                return "􀌣"
            case .exit:
                return "􀆄"
                
            }
        }
    }
}
