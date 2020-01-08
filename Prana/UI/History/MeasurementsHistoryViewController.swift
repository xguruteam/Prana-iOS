//
//  MeasurementsHistoryViewController.swift
//  Prana
//
//  Created by Guru on 6/26/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class MeasurementsHistoryViewController: SuperViewController {

    @IBOutlet weak var ddArea: PranaDropDown!
    @IBOutlet weak var lblWeekRange: UILabel!
    
    @IBOutlet weak var lblMonthRange: UILabel!
    @IBOutlet weak var btnUnit: UIButton!
    
    @IBOutlet weak var weeklyGraph: WeeklyGraph2!
    @IBOutlet weak var monthlyGraph: MonthlyGraph!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnUnit.titleLabel?.font = UIFont.bold(ofSize: 16)
        ddArea.clickListener = { [unowned self] in
            self.openBodyAreaPicker()
        }
                
        weeklyGraph.diaryClickHandler = { [unowned self] (id, note) in
            let vc = Utils.getStoryboardWithIdentifier(identifier: "DiaryViewController") as! DiaryViewController
            let date = self.wb.adding(.day, value: id)
            vc.date = date
            vc.isEditable = false
            vc.note = note
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        currentDate = Date()
        part = .neck
        unit = .inch
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onWeekLeft(_ sender: Any) {
        currentDate = currentDate.adding(.day, value: -7)
    }
    
    @IBAction func onWeekRight(_ sender: Any) {
        currentDate = currentDate.adding(.day, value: 7)
    }
    
    @IBAction func onMonthLeft(_ sender: Any) {
        currentDate = mb.adding(.day, value: -1)
    }
    
    @IBAction func onMonthRight(_ sender: Any) {
        currentDate = me.adding(.day, value: 1)
    }
    
    @IBAction func onChangeUnit(_ sender: Any) {
        if unit == .inch {
            unit = .cm
        } else {
            unit = .inch
        }
    }
    
    func openBodyAreaPicker() {
        tempPart = part
        let alert = UIAlertController(style: .actionSheet, title: "Body Area", message: nil)
        
        let frameSizes: [Int] = (0 ..< keys.count).map { Int($0) }
        let pickerViewValues: [[String]] = [frameSizes.map { values[$0] }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: keys.index(of: tempPart) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempPart = self.keys[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.part = self.tempPart
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    var unit: MeasurementUnit = .inch {
        didSet {
            if unit == .inch {
                btnUnit.setTitle("INCHES", for: .normal)
            } else {
                btnUnit.setTitle("CENTMETERS", for: .normal)
            }
            reloadMeasurementData()
        }
    }
    
    var currentDate: Date = Date() {
        didSet {
            mb = currentDate.beginning(of: .month)!
            me = currentDate.end(of: .month)!
            wb = currentDate.previous(.monday, considerToday: true)
            we = currentDate.next(.sunday, considerToday: true)
            
            lblWeekRange.text = "\(wb.dateString()) - \(we.dateString())"
            let fomatter = DateFormatter()
            fomatter.dateFormat = "MMMM yyyy"
            lblMonthRange.text = fomatter.string(from: mb)
            
            weeklyMeasurements = dataController.fetchWeeklyMeasurement(date: currentDate)
            monthlyMeasurements = dataController.fetchMonthlyMeasurement(date: currentDate)
            
            reloadMeasurementData()
        }
    }
    
    var wb, we, mb, me: Date!
    
    let bodyPart: [BMPosition: String] = [
        .neck: "Neck",
        .shoulders: "Shoulders",
        .chest: "Chest",
        .waist: "Waist",
        .hips: "Hips",
        .larm: "Left Arm",
        .lfarm: "Right Arm",
        .lwrist: "Left Wrist",
        .rarm: "Right Arm",
        .rfarm: "Right Arm",
        .rwrist: "Right Wrist",
        .lthigh: "Left Thigh",
        .lcalf: "Left Calf",
        .rthigh: "Right Thigh",
        .rcalf: "Right Calf",
        .custom1: "Custom 1",
        .custom2: "Custom 2",
        .custom3: "Custom 3",
    ]
    
    let values: [String] = [
        "Neck",
        "Shoulders",
        "Chest",
        "Waist",
        "Hips",
        "Left Arm",
        "Right Arm",
        "Left Wrist",
        "Right Arm",
        "Right Arm",
        "Right Wrist",
        "Left Thigh",
        "Left Calf",
        "Right Thigh",
        "Right Calf",
        "Custom 1",
        "Custom 2",
        "Custom 3",
    ]
    
    let keys: [BMPosition] = [
        .neck,
        .shoulders,
        .chest,
        .waist,
        .hips,
        .larm,
        .lfarm,
        .lwrist,
        .rarm,
        .rfarm,
        .rwrist,
        .lthigh,
        .lcalf,
        .rthigh,
        .rcalf,
        .custom1,
        .custom2,
        .custom3,
    ]
    
    var part: BMPosition = .neck {
        didSet {
            ddArea.title = bodyPart[part]!
            reloadMeasurementData()
        }
    }
    
    var tempPart: BMPosition!
    
    var weeklyMeasurements: [Measurement] = []
    var monthlyMeasurements: [Measurement] = []
    
    func reloadMeasurementData() {
        
        var measurements = weeklyMeasurements
        var parted = measurements.map { (object) -> (Date, Float, String?) in
            let date = object.date
            let value: Float = object.data[part] ?? 0
            let diary = object.note
            return (date, value, diary)
        }
        
        var weekRangedSeries: [(Float, String?)] = []
        
        for i in 0...6 {
            let day = wb.adding(.day, value: i)
            let dayMea = parted.filter { (item) -> Bool in
                let (date, _, _) = item
                return Calendar.current.isDate(date, inSameDayAs: day)
            }
            if let mea = dayMea.last {
                weekRangedSeries.append((mea.1, mea.2))
            } else {
                weekRangedSeries.append((0, nil))
            }
        }
        
        weeklyGraph.color = UIColor(hexString: "#9fd93f")
        weeklyGraph.unit = unit
        weeklyGraph.barData = weekRangedSeries
        weeklyGraph.setNeedsDisplay()
        
        
        measurements = monthlyMeasurements
        parted = measurements.map { (object) -> (Date, Float, String?) in
            let date = object.date
            let value: Float = object.data[part] ?? 0
            let diary = object.note
            return (date, value, diary)
        }
        
        var monthRangedSeries: [Float] = []
        
        let b = Calendar.current.dateComponents([.day], from: mb).day! - 1
        let e = Calendar.current.dateComponents([.day], from: me).day! - 1
        for i in b...e {
            let day = mb.adding(.day, value: i)
            let dayMea = parted.filter { (item) -> Bool in
                let (date, _, _) = item
                return Calendar.current.isDate(date, inSameDayAs: day)
            }
            if let mea = dayMea.last {
                monthRangedSeries.append(mea.1)
            } else {
                monthRangedSeries.append(0)
            }
        }
        
        monthlyGraph.color = UIColor(hexString: "#9fd93f")
        monthlyGraph.unit = unit
        monthlyGraph.series = monthRangedSeries
        monthlyGraph.setNeedsDisplay()
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
