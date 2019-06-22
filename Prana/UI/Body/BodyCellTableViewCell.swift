//
//  BodyCellTableViewCell.swift
//  Prana
//
//  Created by Guru on 6/22/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BodyCellTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var swOnOff: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
