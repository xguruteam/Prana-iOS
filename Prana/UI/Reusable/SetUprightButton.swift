//
//  SetUprightButton.swift
//  Prana
//
//  Created by Guru on 3/18/20.
//  Copyright © 2020 Prana. All rights reserved.
//

import UIKit

class SetUprightButton: UIButton {

    let gradientLayer: CAGradientLayer = {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)].map { $0.withAlphaComponent(1.0).cgColor }
        gradient.locations = [0.0, 1.0]
        return gradient
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                gradientLayer.removeFromSuperlayer()
                self.backgroundColor = .lightGray
            } else {
                gradientLayer.frame = self.bounds
                self.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }

}
