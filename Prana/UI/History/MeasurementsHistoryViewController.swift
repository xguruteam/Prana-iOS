//
//  MeasurementsHistoryViewController.swift
//  Prana
//
//  Created by Guru on 6/26/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import DropDown

class MeasurementsHistoryViewController: SuperViewController {

    @IBOutlet weak var btnUnit: UIButton!
    @IBOutlet weak var historyTableView: UITableView!
    
    let unitDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        historyTableView.estimatedRowHeight = 500
        
        btnUnit.titleLabel?.font = UIFont.bold(ofSize: 16)
        btnUnit.setImage(UIImage(named: "ic_arrow_down_white"), for: .normal)
        btnUnit.tintColor = .white
        btnUnit.semanticContentAttribute = .forceRightToLeft
        btnUnit.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        
        // The view to which the drop down will appear on
        unitDropDown.anchorView = btnUnit
        unitDropDown.dataSource = ["INCHES", "CENTMETERS"]
        unitDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            #if DEBUG
            print("Selected item: \(item) at index: \(index)")
            #endif
            if index == 0 {
                self.unit = .inch
            } else {
                self.unit = .cm
            }
            self.btnUnit.setTitle(item, for: .normal)
        }
        
        // Will set a custom width instead of the anchor view width
        unitDropDown.width = 200
        
//        ddArea.clickListener = { [unowned self] in
//            self.openBodyAreaPicker()
//        }
        
//        weeklyGraph.diaryClickHandler = { [unowned self] (id, note) in
//            let vc = Utils.getStoryboardWithIdentifier(identifier: "DiaryViewController") as! DiaryViewController
//            let date = self.wb.adding(.day, value: id)
//            vc.date = date
//            vc.isEditable = false
//            vc.note = note
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
        let currentDate = Date()
        unit = .inch
        
        let measuredBodyPositions = dataController.fetchMeasuredBodyPart()
        print(measuredBodyPositions)
        cellData = measuredBodyPositions.map {
            return MeasurementHistoryCellModel(position: $0, date: currentDate)
        }

        reloadMeasurementData()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onChangeUnit(_ sender: Any) {
        unitDropDown.show()
    }
    
//    let values: [String] = [
//        "Neck",
//        "Shoulders",
//        "Chest",
//        "Waist",
//        "Hips",
//        "Left Arm",
//        "Right Arm",
//        "Left Wrist",
//        "Right Arm",
//        "Right Arm",
//        "Right Wrist",
//        "Left Thigh",
//        "Left Calf",
//        "Right Thigh",
//        "Right Calf",
//        "Custom 1",
//        "Custom 2",
//        "Custom 3",
//    ]
//
    
    var unit: MeasurementUnit = .inch {
        didSet {
            reloadMeasurementData()
        }
    }
    
    var cellData: [MeasurementHistoryCellModel] = []
    
    func reloadMeasurementData() {
        historyTableView.reloadData()
    }
}

extension MeasurementsHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementHistoryTableViewCell") as! MeasurementHistoryTableViewCell
        cell.configure(data: cellData[indexPath.row], unit: self.unit)
        return cell
    }
}
