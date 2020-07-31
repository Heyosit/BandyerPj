//
//  ButtonStyle.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 31/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

enum ButtonStyle {
    case video
    case microphone
    case flipCamera
    case exit
    
    var backgroundColor: UIColor {
        switch self {
        case .video,
             .microphone,
             .flipCamera:
            return UIColor.darkGray
        case .exit:
            return UIColor.red
        }
    }
    
    func iconName(isActive: Bool = false) -> String {
        switch self {
        case .video:
            return isActive ? "􀍊" : "􀍎"
        case .microphone:
            return isActive ? "􀊱" : "􀊳"
        case .flipCamera:
            return "􀌣"
        case .exit:
            return "􀆄"
            
        }
    }
}
