//
//  OvalButton.swift
//  Prana
//
//  Created by Shine Man on 12/29/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit


class OvalButton: UIButton {

    override var isSelected: Bool {
        didSet {
            configure()
        }
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.layer.cornerRadius = self.bounds.width / 2
        self.transform = CGAffineTransform(scaleX: 1, y: self.bounds.height / self.bounds.width)
        
        self.backgroundColor = UIColor.black
    }

}
