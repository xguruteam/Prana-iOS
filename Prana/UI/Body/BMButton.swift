//
//  BMself.swift
//  Prana
//
//  Created by Guru on 6/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BMButton: UIButton {
    
    var position: String = "Positions" {
        didSet {
            updateTitle()
        }
    }
    
    var value: Float = 0.0 {
        didSet {
            updateTitle()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            configure()
        }
    }
    
    convenience init(position: String) {
        self.init(type: .custom)
        
        self.position = position
        
        updateTitle()
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configure()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        
        if isSelected {
            self.backgroundColor = UIColor(hexString: "#9fd93f")
            self.setTitleColor(.black, for: .normal)
        }
        else {
//            self.backgroundColor = UIColor(hexString: "#7668738b")
            self.backgroundColor = UIColor(red: 0x68 / 255.0, green: 0x73 / 255.0, blue: 0x8b / 255.0, alpha: 0x76 / 255.0)
//            self.alpha = 0x76 / 255.0
            
            if value == 0 {
                self.setTitleColor(.black, for: .normal)
            }
            else {
                self.setTitleColor(.white, for: .normal)
            }
        }
        
        self.layer.cornerRadius = 2
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 11)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 2
    }
    
    func updateTitle() {
        if value == 0 {
            self.setTitle("\(position)\n--", for: .normal)
        }
        else {
            self.setTitle("\(position)\n\(value)", for: .normal)
        }
        configure()
    }
}
