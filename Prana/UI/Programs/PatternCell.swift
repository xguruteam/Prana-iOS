//
//  PatternCell.swift
//  Prana
//
//  Created by Guru on 5/10/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PatternCell: UICollectionViewCell {
    
    @IBOutlet weak var roundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        roundView.layer.shadowOpacity = 0.45
        roundView.layer.shadowRadius = 5
        roundView.layer.shadowColor = UIColor(hexString: "#bac3d7").cgColor
        
        roundView.layer.cornerRadius = 8
        roundView.layer.masksToBounds = false
        
        roundView.backgroundColor = UIColor(hexString: "#bac3d7")
        
    }
}
