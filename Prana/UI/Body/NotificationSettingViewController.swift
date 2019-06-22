//
//  NotificationSettingViewController.swift
//  Prana
//
//  Created by Guru on 6/21/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class NotificationSettingViewController: UIViewController {

    @IBOutlet weak var tableVie: UITableView!
    @IBOutlet weak var btnNot1: PranaButton!
    @IBOutlet weak var btnNot2: PranaButton!
    @IBOutlet weak var btnNot3: PranaButton!
    @IBOutlet weak var ddPeriod: PranaDropDown!
    @IBOutlet weak var titleContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func onBack(_ sender: Any) {
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
        }
    }
    
    let areas = [
        "Neck", "Shoulders", "Chest", "Arms", "Forearms", "Wrists", "Waist", "Hips", "Thighs", "Calves", "Custom 1", "Custom 2", "Custom 3"
    ]
    
    let periodTitles = [
        "Never", "Every 1 day", "Every 3 days", "Every 5 days", "Every 7 days", "Every 14 days", "Every 28 days"
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
        alert.addAction(title: "Done", style: .default) { (_) in
            self.period = self.tempPeriod
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
        cell.swOnOff.isOn = false
        
        if indexPath.row == areas.count - 1 {
            cell.container.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10)
        } else {
            cell.container.roundCorners(corners: [], radius: 10)
        }
        
        return cell
    }
}
