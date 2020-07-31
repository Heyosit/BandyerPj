//
//  RoundIconButton.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class RoundIconButton: UIButton {
    
    var active = false { didSet { didUpdateActive() } }
    
    private var type: ButtonStyle = .video
    
    
    convenience init(type: ButtonStyle) {
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
            heightAnchor.constraint(equalToConstant: RoundIconButton.buttonHeightWidth),
            widthAnchor.constraint(equalToConstant: RoundIconButton.buttonHeightWidth),
            
        ])
    }
    
    private func setupProperties() {
        self.layer.cornerRadius = 35
        self.layer.masksToBounds = true
        
    }
    
    private func setupButtonStyle() {
        self.backgroundColor = type.backgroundColor
        if let image = UIImage(named: type.iconName(isActive: active)) {
            self.setImage(image.withRenderingMode(.automatic), for: .normal)
        }
    }
    
    func didUpdateActive() {
        DispatchQueue.main.async {
            if let image = UIImage(named: self.type.iconName(isActive: self.active)) {
                self.setImage(image.withRenderingMode(.automatic), for: .normal)
            }
        }
    }
    
}

//MARK: Constants

extension RoundIconButton {
    static let buttonHeightWidth: CGFloat = 70
}

