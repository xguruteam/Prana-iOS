//
//  WeeklyCell1.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class WeeklyCell1: UITableViewCell {

    @IBOutlet weak var btnTraining: PranaButton!
    @IBOutlet weak var btnTracking: PranaButton!
    
    
    @IBAction func onButtonClick(_ sender: PranaButton) {
        btnTracking.isClicked = false
        btnTraining.isClicked = false
        
        if sender.tag == 0 {
            btnTraining.isClicked = true
        } else {
            btnTracking.isClicked = true
        }
        
        typeChangeHandler?(sender.tag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var typeChangeHandler: ((Int) -> ())?

}
