//
//  UIButton_Gradient.swift
//  Prana
//
//  Created by Shine Man on 12/29/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
 
    func applyButtonGradient(colors: [UIColor], points: [NSNumber]) {        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.withAlphaComponent(1.0).cgColor }
        gradient.locations = points
        
        self.layer.addSublayer(gradient)
        self.layer.insertSublayer(gradient, at: 0)        
    }
}
