//
//  BlurView.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 29/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class BlurView: UIView {
    
     // MARK: - UI
    
    private lazy var blurVisualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: BlurView.descriptionLabelFontSize, weight: .regular)
        return label
    }()
    
    // MARK: - Properties
    
    var descriptionText: String = "" { didSet { didUpdateDescriptionText() } }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
        self.addSubview(blurVisualEffectView)
        self.addSubview(descriptionLabel)
        
        blurVisualEffectView.anchor(to: self)
        
        NSLayoutConstraint.activate([
            descriptionLabel.heightAnchor.constraint(equalToConstant: BlurView.descriptionLabelHeight),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: BlurView.descriptionLabelSideSpacing),
            self.trailingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: BlurView.descriptionLabelSideSpacing),
        ])
    }
    
    private func didUpdateDescriptionText() {
        descriptionLabel.text = descriptionText
    }
    
}

//MARK: Constants

extension BlurView {
    
    static let descriptionLabelFontSize: CGFloat = 23
    static let descriptionLabelHeight: CGFloat = 200
    static let descriptionLabelSideSpacing: CGFloat = 50
}
