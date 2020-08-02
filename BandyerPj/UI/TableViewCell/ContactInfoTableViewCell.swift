//
//  ContactInfoTableViewCell.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 28/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class ContactInfoTableViewCell: UITableViewCell {
    
    private var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.clear
        return containerView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: ContactInfoTableViewCell.nameLabelFontSize, weight: .bold)
        return label
    }()
    
    private lazy var telephoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupCellProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        containerView.addSubview(nameLabel)
        containerView.addSubview(telephoneLabel)
        
        self.addSubview(containerView)
        
        containerView.anchor(to: self)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ContactInfoTableViewCell.topBottomLabelSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ContactInfoTableViewCell.leadingLabelSpacing),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            telephoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: ContactInfoTableViewCell.topBottomLabelSpacing),
            telephoneLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ContactInfoTableViewCell.leadingLabelSpacing),
            telephoneLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: telephoneLabel.bottomAnchor, constant: ContactInfoTableViewCell.topBottomLabelSpacing),
            
        ])
    }
    
    private func setupCellProperties() {
        self.backgroundColor = .white
    }
    
    func config(contact: Contact) {
        nameLabel.text = contact.name
        telephoneLabel.text = contact.telephoneNumber
    }
}

//MARK: Constants

extension ContactInfoTableViewCell {
    
    static var leadingLabelSpacing: CGFloat = 15
    static var topBottomLabelSpacing: CGFloat = 5
    static var nameLabelFontSize: CGFloat = 16
}
