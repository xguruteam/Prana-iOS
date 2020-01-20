//
//  UIButton.swift
//  Prana
//
//  Created by Luccas on 4/2/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ImageButton: UIButton {
    
    @IBInspectable var titleText: String? {
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

extension UIView {
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        layer.mask = mask
        layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
    }
}

@IBDesignable class PranaButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func commonInit() {
        if isClicked {
            backgroundColor = UIColor.colorFromHex(hexString: "#2BB7B8")
            tintColor = .white
            layer.shadowColor = UIColor.colorFromHex(hexString: "#2BB7B8").cgColor
        }
        else {
            backgroundColor = UIColor.colorFromHex(hexString: "#F8F9FB")
            tintColor = UIColor.colorFromHex(hexString: "#79859F")
            layer.shadowColor = UIColor.colorFromHex(hexString: "#79859F").cgColor
        }
        
        titleLabel?.font = UIFont.medium(ofSize: 15)
        layer.cornerRadius = 4.0
        
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 7.0
        
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
    }
    
    @IBInspectable var isClicked: Bool = false {
        didSet {
            if isClicked {
                backgroundColor = UIColor.colorFromHex(hexString: "#2BB7B8")
                tintColor = .white
                layer.shadowColor = UIColor.colorFromHex(hexString: "#2BB7B8").cgColor
            }
            else {
                backgroundColor = UIColor.colorFromHex(hexString: "#F8F9FB")
                tintColor = UIColor.colorFromHex(hexString: "#79859F")
                layer.shadowColor = UIColor.colorFromHex(hexString: "#79859F").cgColor
            }
            
            titleLabel?.font = UIFont.medium(ofSize: 15)
            
            layer.cornerRadius = 4.0
            
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 7.0
            
            titleLabel?.lineBreakMode = .byWordWrapping
            titleLabel?.textAlignment = .center
        }
    }
}
