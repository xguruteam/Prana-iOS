//
//  SessionHistoryViewController.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SessionHistoryViewController: SuperViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnRangeType1: PranaButton!
    @IBOutlet weak var btnRangeType2: PranaButton!
    @IBOutlet weak var lblWeekRange: UILabel!
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onChangeRangeType(_ sender: UIButton) {
        if sender.tag == 0 {
            rangeType = .daily
        } else {
            rangeType = .weekly
        }
    }
    
    @IBAction func onLeft(_ sender: Any) {
        self.currentDate = self.currentDate.adding(.day, value: -7)
    }
    
    @IBAction func onRight(_ sender: Any) {
        self.currentDate = self.currentDate.adding(.day, value: 7)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        currentDate = Date()
        rangeType = .daily
    }
    
    enum RangeType {
        case daily
        case weekly
    }
    
    var rangeType: RangeType = .daily {
        didSet {
            if rangeType == .daily {
                btnRangeType1.isClicked = true
                btnRangeType2.isClicked = false
                reloadDailySessionData()
            } else {
                btnRangeType1.isClicked = false
                btnRangeType2.isClicked = true
                reloadWeeklySessionData()
            }
        }
    }
    
    var sessionType: SessionType = .session

    var currentDate: Date = Date() {
        didSet {
            begin = currentDate.previous(.monday, considerToday: true)
            end = currentDate.next(.sunday, considerToday: true)
            lblWeekRange.text = "\(begin.dateString()) - \(end.dateString())"
            
            if rangeType == .daily {
                reloadDailySessionData()
            } else {
                reloadWeeklySessionData()
            }
        }
    }
    var begin: Date!
    var end: Date!
    
    var currentSessions: [AnyObject] = []
    var currentSessionSummary: String = ""
    
    typealias DailySummary = (Date, String)
    typealias DailyRow = Any
    var dailyRows: [DailyRow] = []
    
    func reloadDailySessionData() {
        guard rangeType == .daily else { return }
        currentSessions = dataController.fetchWeeklySessions(date: currentDate)
        
        dailyRows = []
        
        for week in 0...6 {
            let day = begin.adding(.day, value: week)
            
            let daySessions = currentSessions.filter { (session) -> Bool in
                if session is TrainingSession {
                    let session = session as! TrainingSession
                    return Calendar.current.isDate(session.startedAt, inSameDayAs: day)
                } else {
                    let passive = session as! PassiveSession
                    return Calendar.current.isDate(passive.startedAt, inSameDayAs: day)
                }
            }
            
            if daySessions.count > 0 {
                let dailySummary = getDailySessionSummary(daySessions)
                dailyRows.insert(contentsOf: daySessions, at: 0)
                dailyRows.insert((day, dailySummary), at: 0)
            }
        }
        
        if dailyRows.count == 0 {
            dailyRows.insert((currentDate, "No Sessions"), at: 0)
        }
        
        tableView.reloadData()
    }
    
    func getDailySessionSummary(_ sessions: [AnyObject]) -> String {
        
        if sessions.count == 0 {
            return "No Sessions"
        }
        
        var breathTime = 0
        var mindfulTime = 0
        var breathCount = 0
        var mindfulCount = 0
        var rrSum: Double = 0
        var sessionCount = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        for object in sessions {
            guard let session = object as? TrainingSession else { continue }
            if session.kind == 0 || session.kind == 1 {
                breathTime += session.duration
                let sum = session.sumMindfulTime()
                mindfulTime += sum.0
                rrSum += sum.1
                mindfulCount += sum.2
                breathCount += session.breaths.count
                sessionCount += 1
            }
            
            if session.kind == 0 || session.kind == 2 {
                postureTime += session.duration
                slouchTime += session.sumSlouchTime()
            }
        }
        
        if sessionCount > 0 {
            rrSum /= Double(sessionCount)
        }
        
        uprightTime = postureTime - slouchTime
        
        var mindfulPercent:Float = 0
        if breathCount > 0 {
            mindfulPercent = getPercent(mindfulCount, breathCount)
        }
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        return """
        Breath Training Time Completed: \(breathTime / 60) Mins
        Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))%
        Mindful Breath Minutes: \(roundFloat(Float(mindfulTime) / 60, point: 1))
        Average Training RR: \(roundFloat(Float(rrSum), point: 2))
        
        Posture Training Time Completed: \(postureTime / 60) Mins
        Upright Posture: \(roundFloat(uprightPercent, point: 1))%
        Upright Posture Minutes: \(roundFloat(Float(uprightTime) / 60, point: 1))
        """
    }
    
    
    var type: SessionType = .session {
        didSet {
            if rangeType == .weekly {
                reloadWeeklySessionData()
            }
        }
    }
    
    func reloadWeeklySessionData() {
        guard rangeType == .weekly else { return }
        if type == .session {
            currentSessions = dataController.fetchWeeklySessions(date: currentDate, type: "TS")
        } else {
            currentSessions = dataController.fetchWeeklySessions(date: currentDate, type: "PS")
        }
        
        tableView.reloadData()
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

extension SessionHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if rangeType == .daily {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rangeType == .daily {
            return dailyRows.count
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rangeType == .daily {
            let row = dailyRows[indexPath.row]
            
            switch row {
            case is DailySummary:
                return 230
            case is TrainingSession:
                return 120
            case is PassiveSession:
                return 100
            default:
                return 0
            }
        }
        
        if indexPath.row == 0 {
            return 57
        }
        return 500
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rangeType == .daily {
            let row = dailyRows[indexPath.row]
            
            switch row {
            case let session as TrainingSession:
                let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
                vc.type = .session
                vc.session = session
                self.navigationController?.pushViewController(vc, animated: true)
            case let passive as PassiveSession:
                let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
                vc.type = .passive
                vc.passive = passive
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if rangeType == .daily {
            
            let row = dailyRows[indexPath.row]
            
            switch row {
            case let summary as DailySummary:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell1") as! DailyCell1
                cell.date = summary.0
                cell.lblSummary.text = summary.1
                cell.dateChangeHandler = { [unowned self] newDate in
                    self.currentDate = newDate
                }
                return cell
            case let session as TrainingSession:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell2") as! DailyCell2
                cell.lblTime.text = session.startedAt.timeString()
                cell.lblSummary.text = session.summary
                
                return cell
            case let passive as PassiveSession:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell2") as! DailyCell2
                cell.lblTime.text = passive.startedAt.timeString()
                cell.lblSummary.text = passive.summary
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyCell1") as! WeeklyCell1
            
            if type == .session {
                cell.btnTraining.isClicked = true
                cell.btnTracking.isClicked = false
            } else  {
                cell.btnTraining.isClicked = false
                cell.btnTracking.isClicked = true
            }
            cell.typeChangeHandler = { [unowned self] type in
                self.type = (type == 0 ? .session : .passive)
            }
            
            return cell
        }
        
        if type == .session {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyCell2") as! WeeklyCell2
            cell.type = .session
            cell.date = currentDate
            cell.sessions = currentSessions as! [TrainingSession]
            cell.weekChangeHandler = { [unowned self] direction in
                if direction < 0 {
                    self.currentDate = self.currentDate.adding(.day, value: -7)
                } else {
                    self.currentDate = self.currentDate.adding(.day, value: 7)
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyCell2") as! WeeklyCell2
            cell.type = .passive
            cell.date = currentDate
            cell.passives = currentSessions as! [PassiveSession]
            cell.weekChangeHandler = { [unowned self] direction in
                if direction < 0 {
                    self.currentDate = self.currentDate.adding(.day, value: -7)
                } else {
                    self.currentDate = self.currentDate.adding(.day, value: 7)
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
}
