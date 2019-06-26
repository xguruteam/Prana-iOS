//
//  DailyCell1.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class DailyCell1: UITableViewCell {

    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var summaryView: UITextView!
    
    @IBOutlet weak var lblSummary: UILabel!
    @IBAction func onDateClick(_ sender: Any) {
        openDatePicker()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        summaryView.isEditable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var date: Date = Date() {
        didSet {
            btnDate.setTitle(self.date.dateString(), for: .normal)
        }
    }
    var tempDate: Date!
    
    var dateChangeHandler: ((Date) -> ())?
    
    func openDatePicker() {
        self.tempDate = self.date
        let alert = UIAlertController(style: .actionSheet, title: "Select date")
        alert.addDatePicker(mode: .date, date: date, minimumDate: nil, maximumDate: nil) { date in
            // action with selected date
            self.tempDate = date
        }
        alert.addAction(title: "Done", style: .default) { [unowned self] (_) in
            self.date = self.tempDate
            self.dateChangeHandler?(self.date)
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }

}
