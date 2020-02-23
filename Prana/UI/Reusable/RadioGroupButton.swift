//
//  RadioGroupButton.swift
//  Prana
//
//  Created by Shine Man on 12/29/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

protocol RadioGroupButtonDelegate: class {
    func onSelectedIndex(index: Int, sender: RadioGroupButton)
}

@IBDesignable class RadioGroupButton: UIStackView {

    weak var delegate: RadioGroupButtonDelegate?
    var selectedIndex: Int = 0 {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var count: Int = 0 {
        didSet {
            initItems()
        }
    }
    
    @IBInspectable var itemColor: UIColor = UIColor.white {
        didSet {
            configure()
        }
    }
    
    var itemFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initItems()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initItems()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustItems()
    }
    
    func initItems() {
        self.spacing = 20
        
        itemFont = UIFont.medium(ofSize: 14)        
        for i in 0 ..< count {
            let button = UIButton()
            button.setTitle(String(i + 1), for: .normal)
            
            button.tag = i + 1

            button.maskToBounds = false
            button.addTarget(self, action: #selector(onTapped(_:)), for: .touchUpInside)
            
            self.addArrangedSubview(button)
        }
        
        configure()
    }
    
    func adjustItems() {
        self.arrangedSubviews.forEach {
            NSLayoutConstraint(item: $0, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant:0).isActive = true
            NSLayoutConstraint(item: $0, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant:0).isActive = true
            $0.layer.cornerRadius = $0.frame.height / 2.0
            $0.layer.borderColor = itemColor.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    func configure() {
        for view in self.arrangedSubviews {
            let button = view as! UIButton
            button.titleLabel?.font = itemFont
            if view.tag == selectedIndex {
                button.backgroundColor = itemColor
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.white
                button.setTitleColor(itemColor, for: .normal)
            }
        }
        
        self.setNeedsLayout()
    }
    
    @objc private func onTapped(_ sender: UIButton) {
        self.selectedIndex = sender.tag
        delegate?.onSelectedIndex(index: selectedIndex, sender: self)
    }
}
