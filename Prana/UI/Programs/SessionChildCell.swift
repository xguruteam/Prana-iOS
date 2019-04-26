//
//  SessionChildCell.swift
//  Prana
//
//  Created by Guru on 4/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SessionChildCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var staartSessionButton: UIButton!
    
    @IBOutlet weak var btnKind1: PranaButton!
    @IBOutlet weak var btnKind2: PranaButton!
    @IBOutlet weak var btnKind3: PranaButton!
    
    @IBOutlet weak var btnType1: PranaButton!
    @IBOutlet weak var btnType2: PranaButton!
    
    @IBOutlet weak var btnPosition1: PranaButton!
    @IBOutlet weak var btnPosition2: PranaButton!
    @IBOutlet weak var btnPosition3: PranaButton!
    
    @IBOutlet weak var ddSessionDuration: PranaDropDown!
    @IBOutlet weak var ddSessionPattern: PranaDropDown!
    
    @IBOutlet weak var settingContainer: UIView!
    
    @IBOutlet weak var constrain1: NSLayoutConstraint!
    @IBOutlet weak var constrain2: NSLayoutConstraint!
    
    var kindChangeListener: ((Int) -> Void)?
    var typeChangeListener: ((Int) -> Void)?
    var positionChangeListener: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        staartSessionButton.titleLabel?.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onKindChange(_ sender: PranaButton) {
        kindChangeListener?(sender.tag)
    }
    
    @IBAction func onTypeChange(_ sender: UIButton) {
        typeChangeListener?(sender.tag)
    }
    
    @IBAction func onPositionChange(_ sender: UIButton) {
        positionChangeListener?(sender.tag)
    }
    
}
