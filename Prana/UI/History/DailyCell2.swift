//
//  DailyCell2.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class DailyCell2: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var summaryView: UITextView!
    
    @IBOutlet weak var lblSummary: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        summaryView.isEditable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
