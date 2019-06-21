//
//  HelpBodyMeasurementsViewController.swift
//  Prana
//
//  Created by Guru on 6/20/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class HelpBodyMeasurementsViewController: UIViewController {

    @IBOutlet weak var ddBodyArea: PranaDropDown!
    
    let areas = [
        "Neck", "Shoulders", "Chest", "Arms", "Forearms", "Wrists", "Waist", "Hips", "Thighs", "Calves", "Customs"
    ]
    
    var area: Int = 0 {
        didSet {
            ddBodyArea.title = areas[area]
        }
    }
    var tempArea: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ddBodyArea.clickListener = { [unowned self] in
            self.openBodyAreaPicker()
        }
        
        area = 0
    }
    

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func openBodyAreaPicker() {
        tempArea = area
        let alert = UIAlertController(style: .actionSheet, title: "Body Area", message: nil)
        
        let frameSizes: [Int] = (0 ..< areas.count).map { Int($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { areas[$0] }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempArea) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempArea = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.area = self.tempArea
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
