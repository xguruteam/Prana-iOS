//
//  SessionStartStopCell.swift
//  Prana
//
//  Created by Luccas on 5/6/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SessionStartStopCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var staartSessionButton: UIButton!
    
    var sessionStartListener: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        staartSessionButton.titleLabel?.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSessionStart(_ sender: Any) {
        sessionStartListener?()
    }
    
    func changePosition(_ position: Int) {
        switch position {
        case 0:
            positionLabel.text = "Wear: Lower Back"
        case 1:
            positionLabel.text = "Wear: Upper Chest"
        case 2:
            positionLabel.text = "Wear: Lower Back"
        default:
            break
        }
    }
}
