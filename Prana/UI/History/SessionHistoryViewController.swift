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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        rangeType = .daily
        currentDate = Date()
        
    }
    
    enum RangeType {
        case daily
        case weekly
    }
    
    enum SessionType {
        case session
        case passive
    }
    
    var rangeType: RangeType = .daily {
        didSet {
            if rangeType == .daily {
                btnRangeType1.isClicked = true
                btnRangeType2.isClicked = false
            } else {
                btnRangeType1.isClicked = false
                btnRangeType2.isClicked = true
            }
        }
    }
    
    var sessionType: SessionType = .session

    var currentDate: Date = Date() {
        didSet {
            reloadDailySessionData()
        }
    }
    
    var currentSessions: [AnyObject] = []
    var currentSessionSummary: String = ""
    
    func reloadDailySessionData() {
        guard rangeType == .daily else { return }
        currentSessions = dataController.fetchDailySessions(date: currentDate)
        currentSessionSummary = getDailySessionSummary()
        tableView.reloadData()
    }
    
    func getDailySessionSummary() -> String {
        var breathTime = 0
        var mindfulTime = 0
        var rrSum: Double = 0
        var sessionCount = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        for object in currentSessions {
            guard let session = object as? TrainingSession else { continue }
            if session.kind == 0 {
                breathTime += session.duration
                let sum = sumMindfulTime(session.breaths)
                mindfulTime += sum.0
                rrSum += sum.1
                
                postureTime += session.duration
                slouchTime += sumSlouchTime(session.slouches)
                sessionCount += 1
            } else if session.kind == 1 {
                breathTime += session.duration
                let sum = sumMindfulTime(session.breaths)
                mindfulTime += sum.0
                rrSum += sum.1
                sessionCount += 1
            } else {
                postureTime += session.duration
                slouchTime += sumSlouchTime(session.slouches)
            }
        }
        
        if sessionCount > 0 {
            rrSum /= Double(sessionCount)
        }
        
        uprightTime = postureTime - slouchTime
        
        var mindfulPercent:Float = 0
        if breathTime > 0 {
            mindfulPercent = getPercent(mindfulTime, breathTime)
        }
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        return """
        Breath Training Time Completed: \(breathTime / 60) Mins
        Mindful Breaths: \(mindfulPercent)%
        Mindful Breath Minutes: \(mindfulTime / 60)
        Average Training RR: \(rrSum)
        
        Posture Training Time Completed: \(postureTime / 60) Mins
        Upright Posture: \(uprightPercent)%
        Upright Posture Minutes: \(uprightTime / 60)
        """
    }
    
    func sumMindfulTime(_ breaths: [BreathRecord]) -> (Int, Double) {
        var mindfulTime = 0
        var avgRR: Double = 0
        for i in 0..<breaths.count {
            let breath = breaths[i]
            if breath.isMindful {
                if i == 0 {
                    mindfulTime += breath.timeStamp
                } else {
                    mindfulTime += (breath.timeStamp - breaths[i - 1].timeStamp)
                }
            }
            avgRR += breath.respRate
        }
        if breaths.count > 0 {
            avgRR += (avgRR / Double(breaths.count))
        }
        
        return (mindfulTime, avgRR)
    }
    
    func sumSlouchTime(_ slouches: [SlouchRecord]) -> Int {
        var slouchTime = 0
        for i in 0..<slouches.count {
            let slouch = slouches[i]
            slouchTime += slouch.duration
        }
        return slouchTime
    }
    
    func getPercent(_ child: Int, _ parent: Int) -> Float {
        let x = Float(child * 100)
        let y = x / Float(parent)
        
        return y
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
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rangeType == .daily {
            if section == 0 { return 1 }
            return currentSessions.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rangeType == .daily {
            if indexPath.section == 0 {
                return 250
            }
            
            return 120
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rangeType == .daily {
            if indexPath.section != 0 {
                let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
                if let session = currentSessions[indexPath.row] as? TrainingSession {
                    vc.type = .session
                    vc.session = session
                } else {
                    let passive = currentSessions[indexPath.row] as! PassiveSession
                    vc.type = .passive
                    vc.passive = passive
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if rangeType == .daily {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell1") as! DailyCell1
                
                cell.date = currentDate
//                cell.summaryView.text = currentSessionSummary
                cell.lblSummary.text = currentSessionSummary
                cell.dateChangeHandler = { [unowned self] newDate in
                    self.currentDate = newDate
                }
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell2") as! DailyCell2
            
            if let session = currentSessions[indexPath.row] as? TrainingSession {
                cell.lblTime.text = session.startedAt.timeString()
//                cell.summaryView.text = session.summary
                cell.lblSummary.text = session.summary
                
                return cell
            }
            
            let passive = currentSessions[indexPath.row] as! PassiveSession
            cell.lblTime.text = passive.startedAt.timeString()
//            cell.summaryView.text = passive.summary
            cell.lblSummary.text = passive.summary
            return cell
        }
        
        return UITableViewCell()
    }
}
