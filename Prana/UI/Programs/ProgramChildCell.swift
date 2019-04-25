//
//  ProgramChildCell.swift
//  Prana
//
//  Created by Guru on 4/22/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class ProgramChildCell: UITableViewCell {

    @IBOutlet weak var dailyButton: PranaButton!
    @IBOutlet weak var customButton: PranaButton!
    
    @IBOutlet weak var fourteenContainer: UIView!
    @IBOutlet weak var customContainer: UIView!
    @IBOutlet weak var notificationContainer: UIView!
    
    var programTypeListner: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onProgramTypeChange(_ sender: UIButton) {
        programTypeListner?(sender.tag)
    }
}
