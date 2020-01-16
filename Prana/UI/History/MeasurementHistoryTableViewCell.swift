//
//  MeasurementHistoryTableViewCell.swift
//  Prana
//
//  Created by Shine Man on 1/15/20.
//  Copyright © 2020 Prana. All rights reserved.
//

import UIKit

// must be class
class MeasurementHistoryCellModel {
    init(position: BMPosition, date: Date) {
        self.position = position
        self.selectedDate = date
    }
    var position: BMPosition
    var selectedDate: Date
}

class MeasurementHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDDArea: UILabel!
    @IBOutlet weak var weeklyGraph: WeeklyGraph2!
    @IBOutlet weak var monthlyGraph: MonthlyGraph!
    @IBOutlet weak var lblWeekRange: UILabel!    
    @IBOutlet weak var lblMonthRange: UILabel!
    
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

    var dataController: DataController {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return DataController() }
        
        return appDelegate.dataController
    }
    
    var data: MeasurementHistoryCellModel!

    var weeklyMeasurements: [Measurement] = []
    var monthlyMeasurements: [Measurement] = []
    
    var unit: MeasurementUnit = .inch {
        didSet {
            reloadMeasurementCellData()
        }
    }
    
    var currentDate: Date = Date() {
        didSet {
            self.data.selectedDate = currentDate
            
            let (mbegin, mend) = getMonthlyRange(for: currentDate)
            mb = mbegin
            me = mend
            let (wbegin, wend) = getWeeklyRange(for: currentDate)
            wb = wbegin
            we = wend
            
            lblWeekRange.text = "\(wb.dateString()) - \(we.dateString())"
            let fomatter = DateFormatter()
            fomatter.dateFormat = "MMMM yyyy"
            lblMonthRange.text = fomatter.string(from: mb)
            
            weeklyMeasurements = dataController.fetchWeeklyMeasurement(date: currentDate)
            monthlyMeasurements = dataController.fetchMonthlyMeasurement(date: currentDate)
            
            reloadMeasurementCellData()
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
    

    func configure(data: MeasurementHistoryCellModel, unit: MeasurementUnit) {
        self.data = data
        self.currentDate = data.selectedDate
        self.unit = unit
        
        lblDDArea.text = bodyPart[data.position]
    }
    
    func reloadMeasurementCellData() {
        
        var measurements = weeklyMeasurements
        var parted = measurements.map { (object) -> (Date, Float, String?) in
            let date = object.date
            let value: Float = object.data[self.data.position] ?? 0
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
            let value: Float = object.data[self.data.position] ?? 0
            let diary = object.note
            return (date, value, diary)
        }
        
        var monthRangedSeries: [Float] = []
        
        let numberOfDaysInMonth = Calendar.current.range(of: .day, in: .month, for: mb)?.count ?? 31
        
        for i in 0...numberOfDaysInMonth {
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
}
