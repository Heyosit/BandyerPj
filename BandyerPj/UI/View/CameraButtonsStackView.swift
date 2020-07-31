//
//  CameraButtonsStackView.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class CameraButtonsStackView: UIStackView {
    
    private lazy var videoButton: RoundIconButton = {
        let button = RoundIconButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var microphoneButton: RoundIconButton = {
        let button = RoundIconButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var flipCameraButton: RoundIconButton = {
        let button = RoundIconButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var exitButton: RoundIconButton = {
        let button = RoundIconButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupProperties()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupLayout() {
        addArrangedSubview(videoButton)
        addArrangedSubview(microphoneButton)
        addArrangedSubview(flipCameraButton)
        addArrangedSubview(exitButton)
                
//        NSLayoutConstraint.activate([
//            backImageView.heightAnchor.constraint(equalToConstant: 48),
//            backImageView.widthAnchor.constraint(equalToConstant: 32),
//        ])
    }
    
    private func setupProperties() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
//        self.spacing = ExclamationMarkStackView.stackViewSpacing
        self.distribution = .equalSpacing
    }
    
    
}
