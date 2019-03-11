//
//  SesseionRecordCell.swift
//  Prana
//
//  Created by Luccas on 3/1/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SesseionRecordCell: UITableViewCell {

    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
