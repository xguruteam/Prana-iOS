//
//  BMself.swift
//  Prana
//
//  Created by Guru on 6/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BMButton: UIButton {
    
    var isCustom: Bool = false
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
        
        if isSelected || value > 0 {
            self.backgroundColor = #colorLiteral(red: 0.6235294118, green: 0.8509803922, blue: 0.2470588235, alpha: 1)
            self.setTitleColor(.white, for: .normal)
        }
        else {
            self.backgroundColor = UIColor.white
            self.setTitleColor(#colorLiteral(red: 0.3568627451, green: 0.7294117647, blue: 0.1215686275, alpha: 1), for: .normal)
        }

        self.layer.cornerRadius = 3
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel?.font = UIFont.bold(ofSize: 10)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 2
        
        self.borderWidth = 1
        self.borderColor = #colorLiteral(red: 0.3568627451, green: 0.7294117647, blue: 0.1215686275, alpha: 0.6549295775)
        
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 8
        self.layer.shadowPath = shadowPath.cgPath
        
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
