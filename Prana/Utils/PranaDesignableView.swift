//
//  UIButton.swift
//  Prana
//
//  Created by Luccas on 4/2/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable

class ImageButton: UIButton {
    
    @IBInspectable
    var titleText: String? {
        didSet {
            self.setTitle("SIGN UP", for: .normal)
        }
    }
    
    var bgImage: UIImage? {
        didSet {
            self.setImage(bgImage, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        setup()
    }
    
    func setup() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2.0
        
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleLabel?.textColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}
