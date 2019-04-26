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
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var ddNotificationTime: PranaDropDown!
    @IBOutlet weak var swNotification: UISwitch!
    
    @IBOutlet weak var fourteenContainer: UIView!
    @IBOutlet weak var customContainer: UIView!
    @IBOutlet weak var notificationContainer: UIView!
    
    var programTypeListner: ((Int) -> Void)?
    var startTrainingListner: (() -> Void)?
    var notificationTimeListener: ((Date) -> Void)?
    var notificationEnableChangeListener: ((Bool) -> Void)?
    
    var notificationTime: Date! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            
            ddNotificationTime.title = dateFormatter.string(from: notificationTime!)
        }
    }
    
    var tempNotificationTime: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ddNotificationTime.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openTimePicker()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onProgramTypeChange(_ sender: UIButton) {
        programTypeListner?(sender.tag)
    }
    
    @IBAction func onStartTraining(_ sender: Any) {
        startTrainingListner?()
    }
    
    @IBAction func onNotificationEnableChange(_ sender: UISwitch) {
        notificationEnableChangeListener?(sender.isOn)
    }
    
    func openTimePicker() {
        self.tempNotificationTime = self.notificationTime
        let alert = UIAlertController(style: .actionSheet, title: "Notification Time", message: nil)
        alert.addDatePicker(mode: .time, date: self.tempNotificationTime, minimumDate: nil, maximumDate: nil) { date in
//            Log(date)
            self.tempNotificationTime = date
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.notificationTime = self.tempNotificationTime
            self.notificationTimeListener?(self.notificationTime)
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
        }
        alert.show(style: .prominent)
    }
    
}
