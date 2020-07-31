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
        let button = RoundIconButton(type: RoundIconButton.ButtonType.video)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var microphoneButton: RoundIconButton = {
        let button = RoundIconButton(type: RoundIconButton.ButtonType.microphone)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var flipCameraButton: RoundIconButton = {
        let button = RoundIconButton(type: RoundIconButton.ButtonType.flipCamera)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var exitButton: RoundIconButton = {
        let button = RoundIconButton(type: RoundIconButton.ButtonType.exit)
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
    }
    
    private func setupProperties() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
//        self.spacing = ExclamationMarkStackView.stackViewSpacing
        self.distribution = .equalSpacing
    }
    
    
    
}
