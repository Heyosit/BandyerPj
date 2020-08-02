//
//  UIViewExtension.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 29/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

extension UIView {
    
    func anchor(to view: UIView, constant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: constant),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: constant),
        ])
    }
}
