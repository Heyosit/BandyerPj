//
//  BottomSheetViewController.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

protocol BottomSheetViewControllerDelegate {
    
}

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
    
    var minHeight: CGFloat {
        return UIScreen.main.bounds.height - (30 + UIApplication.shared.statusBarFrame.height)
    }
    
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
           handleView.heightAnchor.constraint(equalToConstant: 5),
           handleView.widthAnchor.constraint(equalToConstant: 40),
           handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
           
           cameraButtonsStackView.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 35),
           cameraButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
           view.trailingAnchor.constraint(equalTo: cameraButtonsStackView.trailingAnchor, constant: 30),
        ])
    }
    
    private func setupProperties() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = BottomSheetViewController.cornerRadius
        view.layer.masksToBounds = true
        setupHandleView()
    }
    
    private func setupHandleView() {
        handleView.layer.cornerRadius = 3
        handleView.layer.masksToBounds = true
    }
    
    private func addGesture() {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        view.addGestureRecognizer(gesture)
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
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            let frame = self.view.frame
            let yComponent = BottomSheetViewController.maxHeight
            self.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height)
        }
    }
    
    @objc private func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if ( y + translation.y >= BottomSheetViewController.maxHeight) && (y + translation.y <= minHeight ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - BottomSheetViewController.maxHeight) / -velocity.y) : Double((minHeight - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.minHeight, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: BottomSheetViewController.maxHeight, width: self.view.frame.width, height: self.view.frame.height)
                }
                
            }, completion: nil)
        }
    }
    
    func configDelegate(with delegate: CameraButtonsStackViewDelegate) {
        cameraButtonsStackView.delegate = delegate
    }
}

extension BottomSheetViewController {
    
    static let maxHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 4
    static let cornerRadius: CGFloat = 12
}


