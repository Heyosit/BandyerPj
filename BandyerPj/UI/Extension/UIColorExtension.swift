//
//  UIColorExtension.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 31/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: UInt32, useAlpha alphaChannel: Bool = false) {
        let mask = 0xFF
        
        let r = Int(hex >> (alphaChannel ? 24 : 16)) & mask
        let g = Int(hex >> (alphaChannel ? 16 : 8)) & mask
        let b = Int(hex >> (alphaChannel ? 8 : 0)) & mask
        let a = alphaChannel ? Int(hex) & mask : 255
        
        let red   = CGFloat(r) / 255
        let green = CGFloat(g) / 255
        let blue  = CGFloat(b) / 255
        let alpha = CGFloat(a) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    enum Common {
        
        static var darkGray: UIColor {
            return UIColor(hex: 0x585957)
        }
    }
}
