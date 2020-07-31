//
//  CameraButtonsStackView.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

protocol CameraButtonsStackViewDelegate: class {
    func cameraButtonsStackViewDelegateDidTapVideoButton()
    func cameraButtonsStackViewDelegateDidTapMicrophoneButton()
    func cameraButtonsStackViewDelegateDidTapFlipCameraButton()
    func cameraButtonsStackViewDelegateDidTapExitButton()
}

final class CameraButtonsStackView: UIStackView {
    
    //MARK: UI
    
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
    
    //MARK: Properties
    
    weak var delegate: CameraButtonsStackViewDelegate?
    
    //MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupProperties()
        setupTarget()
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
        self.distribution = .equalSpacing
    }
    
    private func setupTarget() {
        videoButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        microphoneButton.addTarget(self, action: #selector(microphoneButtonTapped), for: .touchUpInside)
        flipCameraButton.addTarget(self, action: #selector(flipCameraButtonTapped), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    @objc private func videoButtonTapped() {
        delegate?.cameraButtonsStackViewDelegateDidTapVideoButton()
    }
    
    @objc private func microphoneButtonTapped() {
        delegate?.cameraButtonsStackViewDelegateDidTapMicrophoneButton()
    }
    
    @objc private func flipCameraButtonTapped() {
        delegate?.cameraButtonsStackViewDelegateDidTapFlipCameraButton()
    }
    
    @objc private func exitButtonTapped() {
        delegate?.cameraButtonsStackViewDelegateDidTapExitButton()
    }
    
    
    
}
