//
//  MeasurementHistoryTableViewCell.swift
//  Prana
//
//  Created by Shine Man on 1/15/20.
//  Copyright © 2020 Prana. All rights reserved.
//

import UIKit

class MeasurementHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDDArea: UILabel!
    @IBOutlet weak var weeklyGraph: WeeklyGraph2!
    @IBOutlet weak var monthlyGraph: MonthlyGraph!
    @IBOutlet weak var lblWeekRange: UILabel!    
    @IBOutlet weak var lblMonthRange: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onWeekLeft(_ sender: Any) {
    }
    
    @IBAction func onWeekRight(_ sender: Any) {
    }
    
    @IBAction func onMonthLeft(_ sender: Any) {
    }
    @IBAction func onMonthRight(_ sender: Any) {
    }
}
