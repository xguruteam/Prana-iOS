//
//  ProgramChildCell.swift
//  Prana
//
//  Created by Luccas on 4/22/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class ProgramChildCell: UITableViewCell {

    @IBOutlet weak var dailyButton: PranaButton!
    @IBOutlet weak var customButton: PranaButton!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var ddNotificationTime: PranaDropDown!
    @IBOutlet weak var swNotification: UISwitch!
    
    @IBOutlet weak var ddCustomBreathingGoal: PranaDropDown!
    @IBOutlet weak var ddCustomPostureGoal: PranaDropDown!
    
    @IBOutlet weak var programContainer: UIView!
    @IBOutlet weak var fourteenContainer: UIView!
    @IBOutlet weak var customContainer: UIView!
    @IBOutlet weak var lblCustomDescription: UILabel!
    @IBOutlet weak var goalsContainer: UIView!
    @IBOutlet weak var notificationContainer: UIView!
    
    @IBOutlet weak var lbl14Description: UILabel!
    
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
    
    var customBreathingGoal: Int = 0 {
        didSet {
            ddCustomBreathingGoal.title = "\(customBreathingGoal) Minutes"
        }
    }
    var tempBreathingGoal: Int = 0
    var customBreathingGoalChangeListener: ((Int) -> Void)?
    
    var customPostureGoal: Int = 0 {
        didSet {
            ddCustomPostureGoal.title = "\(customPostureGoal) Minutes"
        }
    }
    var tempPostureGoal: Int = 0
    var customPostureGoalChangeListener: ((Int) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ddNotificationTime.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openTimePicker()
        }
        ddCustomBreathingGoal.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openBreathingGoal()
        }
        ddCustomPostureGoal.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPostureGoal()
        }
        
        
        let text: [AttributedTextBlock] = [
            .list("Automatically sets your daily training minutes for breathing and posture, with increasing times over the 14 days.\n"),
            .list("Automatically selects your breath training pattern (slower breathing and stress reduction).\n"),
            .list("Automatically selects when to wear Prana on your lower back or upper chest.\n"),
            .normal("For each training session:\n"),
            .list("Choose whether to train Breathing & Posture, Breathing Only, or Posture Only\n."),
            .list("Choose the length of the session.\n"),
            .list("Choose whether to use Visual or Buzzer training."),
        ]
        
        lbl14Description.attributedText = text.map {
            let att = NSMutableAttributedString(attributedString: $0.text)
            if $0.text.string.contains("For each") {
                att.addAttribute(NSAttributedString.Key.font, value: UIFont.bold(ofSize: 14), range: NSRange(location: 0, length: $0.text.length))
            }
            else {
                att.addAttribute(NSAttributedString.Key.font, value: UIFont.medium(ofSize: 13), range: NSRange(location: 0, length: $0.text.length))
            }
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 0
            att.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: $0.text.length))
            return att
            }.joined(separator: "\n")
        lbl14Description.textColor = UIColor(hexString: "#79859f")
        
        
        let text2: [AttributedTextBlock] = [
            .list("You set your daily training minute goals for breathing and posture.\n"),
            .normal("For each training session:\n"),
            .list("Choose whether to train Breathing & Posture, Breathing Only, or Posture Only.\n"),
            .list("Choose the breathing pattern to train with from our gallery of patterns.\n"),
            .list("Choose whether to train your lower back or upper back posture.\n"),
            .list("Choose the length of the session.\n"),
            .list("Choose whether to use Visual or Buzzer training."),
        ]
        
        lblCustomDescription.attributedText = text2.map {
            let att = NSMutableAttributedString(attributedString: $0.text)
            if $0.text.string.contains("For each") {
                att.addAttribute(NSAttributedString.Key.font, value: UIFont.bold(ofSize: 14), range: NSRange(location: 0, length: $0.text.length))
            }
            else {
                att.addAttribute(NSAttributedString.Key.font, value: UIFont.medium(ofSize: 13), range: NSRange(location: 0, length: $0.text.length))
            }
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 0
            att.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: $0.text.length))
            return att
            }.joined(separator: "\n")
        lblCustomDescription.textColor = UIColor(hexString: "#79859f")
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
    
    func openBreathingGoal() {
        tempBreathingGoal = customBreathingGoal
        let alert = UIAlertController(style: .actionSheet, title: "Breathing Goal", message: nil)
        
        let frameSizes: [Int] = (2...60).map { Int($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0) Minutes" }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempBreathingGoal) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempBreathingGoal = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.customBreathingGoal = self.tempBreathingGoal
            self.customBreathingGoalChangeListener?(self.customBreathingGoal)
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPostureGoal() {
        tempPostureGoal = customPostureGoal
        let alert = UIAlertController(style: .actionSheet, title: "Posture Goal", message: nil)
        
        let frameSizes: [Int] = (2...60).map { Int($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0) Minutes" }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempPostureGoal) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempPostureGoal = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.customPostureGoal = self.tempPostureGoal
            self.customPostureGoalChangeListener?(self.customPostureGoal)
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
}
