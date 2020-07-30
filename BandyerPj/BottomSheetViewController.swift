//
//  BottomSheetViewController.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    
    let maxHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 4
    var minHeight: CGFloat {
        return UIScreen.main.bounds.height - (30 + UIApplication.shared.statusBarFrame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .clear
        addGesture()
    }
    
    private func addGesture() {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurView()
    }
    
    func addBlurView(){
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
            let yComponent = self.maxHeight
            self.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height)
        }
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if ( y + translation.y >= maxHeight) && (y + translation.y <= minHeight ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - maxHeight) / -velocity.y) : Double((minHeight - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.minHeight, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.maxHeight, width: self.view.frame.width, height: self.view.frame.height)
                }
                
            }, completion: nil)
        }
    }
}
