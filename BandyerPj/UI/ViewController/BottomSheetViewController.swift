//
//  BottomSheetViewController.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    
    private var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.Common.darkGray
        return view
    }()
    
    lazy var cameraButtonsStackView: CameraButtonsStackView = {
        let stackView = CameraButtonsStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupProperties()
        addGesture()
    }
    
    private func setupLayout() {
        view.addSubview(handleView)
        view.addSubview(cameraButtonsStackView)
        
        NSLayoutConstraint.activate([
            handleView.heightAnchor.constraint(equalToConstant: BottomSheetViewController.handleViewHeight),
            handleView.widthAnchor.constraint(equalToConstant: BottomSheetViewController.handleViewWidth),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: BottomSheetViewController.handleViewTopSpacing),
            
            cameraButtonsStackView.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: BottomSheetViewController.stackViewTopSpacing),
            cameraButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BottomSheetViewController.stackViewSideSpacing),
            view.trailingAnchor.constraint(equalTo: cameraButtonsStackView.trailingAnchor, constant: BottomSheetViewController.stackViewSideSpacing),
        ])
    }
    
    private func setupProperties() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = BottomSheetViewController.viewControllerCornerRadius
        view.layer.masksToBounds = true
        setupHandleView()
    }
    
    private func setupHandleView() {
        handleView.layer.cornerRadius = BottomSheetViewController.handleViewCornerRadius
        handleView.layer.masksToBounds = true
    }
    
    private func addGesture() {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if ( y + translation.y >= BottomSheetViewController.maxHeight) && (y + translation.y <= BottomSheetViewController.minHeight ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - BottomSheetViewController.maxHeight) / -velocity.y) : Double((BottomSheetViewController.minHeight - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: BottomSheetViewController.minHeight, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: BottomSheetViewController.maxHeight, width: self.view.frame.width, height: self.view.frame.height)
                }
                
            }, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurView()
    }
    
    private func addBlurView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: BottomSheetViewController.animationDuration) { [weak self] in
            guard let self = self else { return }
            let frame = self.view.frame
            let yComponent = BottomSheetViewController.maxHeight
            self.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height)
        }
    }
    
    func configDelegate(with delegate: CameraButtonsStackViewDelegate) {
        cameraButtonsStackView.delegate = delegate
    }
    
    func showViewController() {
        UIView.animate(withDuration: BottomSheetViewController.animationDuration, delay: 0.0, options: [.allowUserInteraction], animations: {
            if  self.view.frame.minY == BottomSheetViewController.maxHeight {
                self.view.frame = CGRect(x: 0, y: BottomSheetViewController.minHeight, width: self.view.frame.width, height: self.view.frame.height)
            }
            else {
                self.view.frame = CGRect(x: 0, y: BottomSheetViewController.maxHeight, width: self.view.frame.width, height: self.view.frame.height)
            }
        }, completion: nil)
    }
}

//MARK: Constants

extension BottomSheetViewController {
    
    static let maxHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 4
    static let minHeight: CGFloat = UIScreen.main.bounds.height
    static let viewControllerCornerRadius: CGFloat = 12
    static let handleViewHeight: CGFloat = 5
    static let handleViewWidth: CGFloat = 40
    static let handleViewCornerRadius: CGFloat = 3
    static let handleViewTopSpacing: CGFloat = 5
    static let stackViewTopSpacing: CGFloat = 35
    static let stackViewSideSpacing: CGFloat = 30
    static let animationDuration: Double = 0.3
}


