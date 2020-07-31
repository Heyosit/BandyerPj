//
//  TitleSubtitleLabelView.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 30/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class TitleSubtitleLabelView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: TitleSubtitleLabelView.titleLabelFontSize, weight: .regular)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: TitleSubtitleLabelView.subtitleLabelFontSize, weight: .regular)
        label.text = TitleSubtitleLabelView.subtitleLabelText
        return label
    }()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupProperties()
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: TitleSubtitleLabelView.subtitleLabelTopSpacing),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupProperties() {
        self.backgroundColor = .clear
        
    }
    
    func config(title: String? = nil, subtitle: String? = nil) {
        titleLabel.text = title ?? ""
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
        }
    }
    
}

//MARK: Constants

extension TitleSubtitleLabelView {
    static let titleLabelFontSize: CGFloat = 45
    static let subtitleLabelFontSize: CGFloat = 30
    static let subtitleLabelText = "Facetime..."
    static let subtitleLabelTopSpacing: CGFloat = 15
}
