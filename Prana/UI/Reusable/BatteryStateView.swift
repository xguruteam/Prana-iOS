//
//  BatteryStateView.swift
//  Prana
//
//  Created by Guru on 5/23/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BatteryStateView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fillView: UIView!
    
    @IBOutlet weak var withConst: NSLayoutConstraint!
    
    var progress: CGFloat = 0 {
        didSet {
            refreshProgress()
        }
    }
    
    @IBInspectable var isGray: Bool = false {
        didSet {
            refreshProgress()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder  aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("BatteryStateView", owner: self, options: nil)
        backgroundColor = .clear
        contentView.fixInView(self)
        refreshProgress()
    }
    
    func refreshProgress() {
        withConst.constant = CGFloat(20.0 * progress)
        
        if isGray {
            fillView.backgroundColor = UIColor(hexString: "#79859f")
            imageView.image = UIImage(named: "ic_battery_gray")
        }
        else {
            fillView.backgroundColor = .white
            imageView.image = UIImage(named: "ic_battery")
        }
    }

}
