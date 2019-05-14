//
//  PranaDropDown.swift
//  Prana
//
//  Created by Guru on 4/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

@IBDesignable
class PranaDropDown: UIView {

    @IBInspectable var title: String = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBInspectable var isBoth: Bool = false {
        didSet {
            if isBoth {
                arrowImage.image = UIImage(named: "ic_arrow_both_white")
            }
            else {
                arrowImage.image = UIImage(named: "ic_arrow_down_white")
            }
        }
    }
    
    var clickListener: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PranaDropDown", owner: self, options: nil)
        
//        backgroundColor = UIColor.colorFromHex(hexString: "#2BB7B8")
        
        layer.shadowColor = UIColor.colorFromHex(hexString: "#2BB7B8").cgColor

//        titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 15.0)
        
        layer.cornerRadius = 4.0
        
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 7.0
        
        contentView.fixInView(self)
        
        if isBoth {
            arrowImage.image = UIImage(named: "ic_arrow_both_white")
        }
        else {
            arrowImage.image = UIImage(named: "ic_arrow_down_white")
        }
    }
    
    @IBAction func onClick(_ sender: Any) {
        clickListener?()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
