//
//  NotificationSettingViewController.swift
//  Prana
//
//  Created by Guru on 6/21/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class NotificationSettingViewController: SuperViewController {

    @IBOutlet weak var tableVie: UITableView!
    @IBOutlet weak var btnNot1: PranaButton!
    @IBOutlet weak var btnNot2: PranaButton!
    @IBOutlet weak var btnNot3: PranaButton!
    @IBOutlet weak var ddPeriod: PranaDropDown!
    @IBOutlet weak var titleContainer: UIView!
    
    var notificationSetting: SavedBodyNotification = SavedBodyNotification()
    
    var index: Int = 0 {
        didSet{
            let setting = notificationSetting.settings[index]
            period = setting.interval
            tableVie.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationCenter.requestAllowNotification()
        
        if let savedSetting = dataController.savedBodyNotification {
            notificationSetting = savedSetting
        }
        
        notification = 0
        
        // Do any additional setup after loading the view.
        btnNot1.isClicked = true
        
        tableVie.delegate = self
        tableVie.dataSource = self
        
        tableVie.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        ddPeriod.clickListener = { [unowned self ] in
            self.openPeriodPicker()
        }
        
        titleContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10)
    }
    
    func removeNotifications() {
        notificationCenter.removeNotifications(identifiers: ["pbmn0", "pbmn1", "pbmn2"])
    }
    
    func scheduleNotifications() {
        removeNotifications()

        var index = 0
        for setting in notificationSetting.settings {
            if setting.interval == 0 { continue }
            let timeInterval = timeIntervals[setting.interval]
            let title = "Prana Reminder"
            let parts = setting.isOn.reduce(([], 0)) { (result, isOn) -> ([String], Int) in
                var (str, index) = result
                if isOn {
                    str.append(areas[index])
                }
                index += 1
                return (str, index)
            }
            let body = "Don't forget to take your body measurements for \(parts.0.joined(separator: ", "))"
            notificationCenter.scheduleIntervalNotification(title: title, body: body, interval: timeInterval, identifier: "pbmn\(index)")
            index += 1
        }
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dataController.savedBodyNotification = self.notificationSetting
        scheduleNotifications()
        dataController.saveSettings()
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func onButtonClick(_ sender: UIButton) {
        notification = sender.tag
    }
    
    var notification: Int = 0 {
        didSet {
            btnNot1.isClicked = false
            btnNot2.isClicked = false
            btnNot3.isClicked = false
            
            switch notification {
            case 0:
                btnNot1.isClicked = true
            case 1:
                btnNot2.isClicked = true
            case 2:
                btnNot3.isClicked = true
            default:
                break
            }
            index = notification
        }
    }
    
    let areas = [
        "Neck", "Shoulders", "Chest", "Arms", "Forearms", "Wrists", "Waist", "Hips", "Thighs", "Calves", "Custom 1", "Custom 2", "Custom 3"
    ]
    
    let periodTitles = [
        "Never", "Every 1 day", "Every 3 days", "Every 5 days", "Every 7 days", "Every 14 days", "Every 28 days"
    ]
    
    let timeIntervals: [TimeInterval] = [
        60 * 0,
        60 * 1,
        60 * 3,
        60 * 5,
        60 * 7,
        60 * 14,
        60 * 28,
//        60 * 60 * 24 * 0,
//        60 * 60 * 24 * 1,
//        60 * 60 * 24 * 3,
//        60 * 60 * 24 * 5,
//        60 * 60 * 24 * 7,
//        60 * 60 * 24 * 14,
//        60 * 60 * 24 * 28,
    ]
    
    var period: Int = 0 {
        didSet {
            ddPeriod.title = periodTitles[period]
        }
    }
    var tempPeriod: Int = 0
    
    func openPeriodPicker() {
        tempPeriod = period
        let alert = UIAlertController(style: .actionSheet, title: "Body Area", message: nil)
        
        let frameSizes: [Int] = [0, 1, 2, 3, 4, 5, 6]
        let pickerViewValues: [[String]] = [frameSizes.map { periodTitles[$0] }]
        
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: tempPeriod)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempPeriod = index.row
            }
        }
        alert.addAction(title: "Done", style: .default) { [unowned self] (_) in
            self.period = self.tempPeriod
            self.notificationSetting.settings[self.index].interval = self.period
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }

}

extension NotificationSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BodyCell") as! BodyCellTableViewCell
        
        cell.lblText.text = areas[indexPath.row]
        let setting = notificationSetting.settings[index]
        cell.swOnOff.isOn = setting.isOn[indexPath.row]
        cell.changeHandler = { [unowned self] isOn in
            self.notificationSetting.settings[self.index].isOn[indexPath.row] = isOn
        }
        
        if indexPath.row == areas.count - 1 {
            cell.container.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10)
        } else {
            cell.container.roundCorners(corners: [], radius: 10)
        }
        
        return cell
    }
}
