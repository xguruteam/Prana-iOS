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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
