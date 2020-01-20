//
//  CustomPatternViewController.swift
//  Prana
//
//  Created by Luccas on 5/13/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class CustomPatternViewController: UIViewController {

    @IBOutlet weak var ovalMask: UIView!
    @IBOutlet weak var radio1: UIButton!
    @IBOutlet weak var radio2: UIButton!
    @IBOutlet weak var drop1: PranaDropDown!
    @IBOutlet weak var drop2: PranaDropDown!
    @IBOutlet weak var drop3: PranaDropDown!
    
    @IBOutlet weak var drop4: PranaDropDown!
    @IBOutlet weak var drop5: PranaDropDown!
    @IBOutlet weak var drop6: PranaDropDown!
    @IBOutlet weak var drop7: PranaDropDown!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    var subType: Int = 0
    
    var startResp: Int = 0
    var tempStartResp: Int = 0
    
    var minimumResp: Int = 0
    var tempMinimumResp: Int = 0
    
    var ratio: Float = 0.5
    var tempRatio: Float = 0
    
    var inhalationTime: Float = 0.5
    var tempInhalationTime: Float = 0
    
    var exhalationTime: Float = 0.5
    var tempExhalationTime: Float = 0
    
    var retentionTime: Float = 0.5
    var tempRetentionTime: Float = 0
    
    var timeBetweenBreaths: Float = 0.5
    var tempTimeBetweenBreaths: Float = 0
    
    var resultResp: Float = 0
    
    var bpms: [Float] = [24, 20, 17.14, 15, 13.3, 12, 10.9, 10, 9.2, 8.6, 8, 7.5, 7.1, 6.7, 6.3, 6, 5.7, 5.5, 5.2, 5, 4.8, 4.6, 4.4, 4.3, 4.1, 4, 3.9, 3.8, 3.6, 3.5, 3.4, 3.3, 3.2, 3.1, 3, ]
    
    var settingChangeListener: ((Int, Int, Int, Float, Float, Float, Float, Float) -> Void)?
    
    var isVT: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isVT == false {
            bpms = [15, 13.3, 12, 10.9, 10, 9.2, 8.6, 8, 7.5, 7.1, 6.7, 6.3, 6, 5.7, 5.5, 5.2, 5, 4.8, 4.6, 4.4, 4.3, 4.1, 4, 3.9, 3.8, 3.6, 3.5, 3.4, 3.3, 3.2, 3.1, 3, ]
        }
        
        if subType == 0 {
            radio1.isSelected = true
        }
        else {
            radio2.isSelected = true
        }
        
        radio1.titleEdgeInsets.left = 10
        radio1.titleLabel?.numberOfLines = 2
        
        radio2.titleEdgeInsets.left = 10
        
        setTitle("Define your Custom\nBreathing Pattern")
        
        
        drop1.title = "\(self.bpms[startResp]) b/m"
        
        drop2.title = "\(self.bpms[minimumResp]) b/m"
        
        drop3.title = "\(ratio)"
        drop4.title = "\(inhalationTime)"
        drop5.title = "\(exhalationTime)"
        drop6.title = "\(retentionTime)"
        drop7.title = "\(timeBetweenBreaths)"
        
        calculateResultRespirationRate()
        
        
        drop1.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker1()
        }

        drop2.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker2()
        }
        
        drop3.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker3()
        }
        
        drop4.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker4()
        }
        
        drop5.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker5()
        }
        
        
        drop6.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker6()
        }
        
        
        drop7.clickListener = { [weak self] in
            guard let self = self else { return }
            self.openPicker7()
        }
        
    }
    
    func calculateResultRespirationRate() {
        let result = 60.0 / (inhalationTime + exhalationTime + retentionTime + timeBetweenBreaths)
        
        let rounded = round(result * 10.0) / 10.0
        
        self.resultResp = rounded
        lblResult.text = "Resulting Respiration Rate: \(rounded) b/m"
    }
    

    @IBAction func onSelect(_ sender: UIButton) {
        if sender.tag == 0 {
            radio1.isSelected = true
            radio2.isSelected = false
        }
        else {
            radio1.isSelected = false
            radio2.isSelected = true
        }
        subType = sender.tag
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.settingChangeListener?(subType, startResp, minimumResp, ratio, inhalationTime, exhalationTime, retentionTime, timeBetweenBreaths)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setTitle(_ title: String) {
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 2)
        shadow.shadowColor = UIColor(hexString: "#910c5274")
        shadow.shadowBlurRadius = 4
        
        let attributes = [
            NSAttributedString.Key.font :  UIFont.medium(ofSize: 15),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow] as [NSAttributedString.Key : Any]
        
        let titleStr = NSAttributedString(string: title, attributes: attributes) //1
        
        lblTitle.attributedText = titleStr //3
    }
    
    func openPicker1() {
        tempStartResp = startResp
        
        let alert = UIAlertController(style: .actionSheet, title: "Start Respiration Rate", message: nil)
        
        let frameSizes: [Int] = (0...bpms.count).map { Int($0) }
        let pickerViewValues: [[String]] = [bpms.map { "\($0) b/m" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempStartResp) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempStartResp = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.startResp = self.tempStartResp
            self.drop1.title = "\(self.bpms[self.startResp]) b/m"
            
            if self.minimumResp < self.startResp { self.minimumResp = self.startResp }
            self.drop2.title = "\(self.bpms[self.minimumResp]) b/m"
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPicker2() {
        tempMinimumResp = minimumResp
        
        let alert = UIAlertController(style: .actionSheet, title: "Minimum Respiration Rate", message: nil)
        
        let frameSizes: [Int] = (0...bpms.count).map { Int($0) }
        let pickerViewValues: [[String]] = [bpms.map { "\($0) b/m" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempMinimumResp) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempMinimumResp = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.minimumResp = self.tempMinimumResp
            self.drop2.title = "\(self.bpms[self.minimumResp]) b/m"
            
            if self.minimumResp < self.startResp { self.startResp = self.minimumResp }
            self.drop1.title = "\(self.bpms[self.startResp]) b/m"
            
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPicker3() {
        tempRatio = ratio
        
        let alert = UIAlertController(style: .actionSheet, title: "Exhalation to inhalation ratio", message: nil)
        
        let frameSizes: [Float] = (1...120).map { Float($0) * 0.5 }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0)" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempRatio) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempRatio = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.ratio = self.tempRatio
            self.drop3.title = "\(self.ratio)"
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPicker4() {
        tempInhalationTime = inhalationTime
        
        let alert = UIAlertController(style: .actionSheet, title: "Inhalation time", message: nil)
        
        let frameSizes: [Float] = (1...120).map { Float($0) * 0.5 }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0)" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempInhalationTime) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempInhalationTime = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.inhalationTime = self.tempInhalationTime
            self.drop4.title = "\(self.inhalationTime)"
            self.calculateResultRespirationRate()
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPicker5() {
        tempExhalationTime = exhalationTime
        
        let alert = UIAlertController(style: .actionSheet, title: "Exhalation time", message: nil)
        
        let frameSizes: [Float] = (1...120).map { Float($0) * 0.5 }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0)" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempExhalationTime) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempExhalationTime = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.exhalationTime = self.tempExhalationTime
            self.drop5.title = "\(self.exhalationTime)"
            self.calculateResultRespirationRate()
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPicker6() {
        tempRetentionTime = retentionTime
        
        let alert = UIAlertController(style: .actionSheet, title: "Retention time", message: nil)
        
        let frameSizes: [Float] = (1...120).map { Float($0) * 0.5 }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0)" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempRetentionTime) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempRetentionTime = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.retentionTime = self.tempRetentionTime
            self.drop6.title = "\(self.retentionTime)"
            self.calculateResultRespirationRate()
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func openPicker7() {
        tempTimeBetweenBreaths = timeBetweenBreaths
        
        let alert = UIAlertController(style: .actionSheet, title: "Time between Breaths", message: nil)
        
        let frameSizes: [Float] = (1...120).map { Float($0) * 0.5 }
        let pickerViewValues: [[String]] = [frameSizes.map { "\($0)" }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempTimeBetweenBreaths) ?? 1)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempTimeBetweenBreaths = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.timeBetweenBreaths = self.tempTimeBetweenBreaths
            self.drop7.title = "\(self.timeBetweenBreaths)"
            self.calculateResultRespirationRate()
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }

}
