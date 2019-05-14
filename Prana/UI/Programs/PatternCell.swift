//
//  PatternCell.swift
//  Prana
//
//  Created by Luccas on 5/10/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PatternCell: UICollectionViewCell {
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    
    var indexPath: IndexPath!
    
    var clickListener: ((IndexPath) -> Void)?
    
    var isDisabled: Bool = false {
        didSet {
            button.isEnabled = !isDisabled
            if isDisabled {
                roundView.alpha = 0.5
            }
            else {
                roundView.alpha = 1
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                roundView.backgroundColor = UIColor(hexString: "#2bb7b8")
            }
            else {
                roundView.backgroundColor = UIColor(hexString: "#bac3d7")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        roundView.layer.shadowOpacity = 0.45
        roundView.layer.shadowRadius = 5
        roundView.layer.shadowColor = UIColor(hexString: "#bac3d7").cgColor
        
        roundView.layer.cornerRadius = 8
        roundView.layer.masksToBounds = false
        
        roundView.backgroundColor = UIColor(hexString: "#bac3d7")
        
        isSelected = false
        isDisabled = false
    }
    
    @IBAction func onClick(_ sender: Any) {
        self.clickListener?(indexPath)
    }
    
}
