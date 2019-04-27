//
//  SessionChildCell.swift
//  Prana
//
//  Created by Guru on 4/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SessionChildCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var staartSessionButton: UIButton!
    
    @IBOutlet weak var btnKind1: PranaButton!
    @IBOutlet weak var btnKind2: PranaButton!
    @IBOutlet weak var btnKind3: PranaButton!
    
    @IBOutlet weak var btnType1: PranaButton!
    @IBOutlet weak var btnType2: PranaButton!
    
    @IBOutlet weak var btnPosition1: PranaButton!
    @IBOutlet weak var btnPosition2: PranaButton!
    @IBOutlet weak var btnPosition3: PranaButton!
    
    @IBOutlet weak var ddSessionDuration: PranaDropDown!
    @IBOutlet weak var ddSessionPattern: PranaDropDown!
    
    @IBOutlet weak var settingContainer: UIView!
    
    @IBOutlet weak var constrain1: NSLayoutConstraint!
    @IBOutlet weak var constrain2: NSLayoutConstraint!
    
    var kindChangeListener: ((Int) -> Void)?
    var typeChangeListener: ((Int) -> Void)?
    var positionChangeListener: ((Int) -> Void)?
    
    var sessionDuration: Int = 0 {
        didSet {
            ddSessionDuration.title = "\(sessionDuration) Minutes"
        }
    }
    var tempSessionDuration: Int = 0
    var sessionDurationChangeListener: ((Int) -> Void)?
    
    var sessionPattern: Int = 0 {
        didSet {
            ddSessionPattern.title = "Focus"
        }
    }
    var tempSessionPattern: Int = 0
    var sessionPatternChangeListener: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        staartSessionButton.titleLabel?.textAlignment = .center
        
        ddSessionDuration.clickListener = { [weak self] in
            self?.openSessionDurationPicker()
        }
        
        ddSessionPattern.clickListener = { [weak self] in
            self?.openSessionPatternPicker()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onKindChange(_ sender: PranaButton) {
        changeKind(sender.tag)
        kindChangeListener?(sender.tag)
    }
    
    @IBAction func onTypeChange(_ sender: UIButton) {
        changeType(sender.tag)
        typeChangeListener?(sender.tag)
    }
    
    @IBAction func onPositionChange(_ sender: UIButton) {
        changePosition(sender.tag)
        positionChangeListener?(sender.tag)
    }
    
    func changeKind(_ kind: Int) {
        btnKind1.isClicked = false
        btnKind2.isClicked = false
        btnKind3.isClicked = false
        switch kind {
        case 0:
            btnKind1.isClicked = true
        case 1:
            btnKind2.isClicked = true
        case 2:
            btnKind3.isClicked = true
        default:
            break
        }
    }
    
    func changeType(_ type: Int) {
        btnType1.isClicked = false
        btnType2.isClicked = false
        switch type {
        case 0:
            btnType1.isClicked = true
        case 1:
            btnType2.isClicked = true
        default:
            break
        }
    }
    
    func changePosition(_ position: Int) {
        btnPosition1.isClicked = false
        btnPosition2.isClicked = false
        btnPosition3.isClicked = false
        switch position {
        case 0:
            btnPosition1.isClicked = true
            positionLabel.text = "Wear: Lower Back"
        case 1:
            btnPosition2.isClicked = true
            positionLabel.text = "Wear: Upper Chest"
        case 2:
            btnPosition3.isClicked = true
            positionLabel.text = "Wear: Lower Back"
        default:
            break
        }
    }
    
    func openSessionDurationPicker() {
        tempSessionDuration = sessionDuration
        let alert = UIAlertController(style: .actionSheet, title: "Posture Goal", message: nil)
        
        let frameSizes: [Int] = (2...60).map { Int($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0) Minutes" }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempSessionDuration) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempSessionDuration = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.sessionDuration = self.tempSessionDuration
            self.sessionDurationChangeListener?(self.sessionDuration)
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openSessionPatternPicker() {
        tempSessionPattern = sessionPattern
        let alert = UIAlertController(style: .actionSheet, title: "Posture Goal", message: nil)
        
        let frameSizes: [Int] = (0...15).map { Int($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { "Pattern \($0)" }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempSessionPattern) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempSessionPattern = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.sessionPattern = self.tempSessionPattern
            self.sessionDurationChangeListener?(self.sessionPattern)
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
}
