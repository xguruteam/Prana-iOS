//
//  WeeklyCell2.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class WeeklyCell2: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        date = Date()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var mindfulView: WeeklyGraph!
    @IBOutlet weak var rrView: WeeklyGraph!
    @IBOutlet weak var uprightView: WeeklyGraph!
    @IBOutlet weak var lblGraphTitle1: UILabel!
    @IBOutlet weak var lblGraphTitle2: UILabel!
    
    @IBAction func onRight(_ sender: Any) {
        weekChangeHandler?(1)
    }
    
    @IBAction func onLeft(_ sender: Any) {
        weekChangeHandler?(-1)
    }
    
    var type: SessionType = .session {
        didSet {
            if type == .session {
                lblGraphTitle1.text = "Mindful Breathing Minutes"
                lblGraphTitle2.text = "Average Daily Respiration Rate"
            } else {
                lblGraphTitle1.text = "Average Daily Respiration Rate"
                lblGraphTitle2.text = "Average Daily Exhalation/Inhalation"
            }
        }
    }
    
    var weekChangeHandler: ((Int) -> ())?
    var date: Date = Date() {
        didSet {
            let (begin, end) = getWeeklyRange(for: date)
            self.begin = begin
            self.end = end
            lblWeek.text = "\(begin.dateString()) - \(end.dateString())"
        }
    }
    
    var begin: Date!
    var end: Date!
    
    var sessions: [TrainingSession]! {
        didSet {
            renderSessionData()
        }
    }
    
    var passives: [PassiveSession]! {
        didSet {
            renderPassiveData()
        }
    }
    
    func renderSessionData() {
        
        var breathTimes: [WeeklyGraph.StackDataType] = []
        var avgRRs: [Double] = []
        var uprightTimes: [WeeklyGraph.StackDataType] = []
        
        for week in 0...6 {
            let day = begin.adding(.day, value: week)
            
            let daySessions = sessions.filter { (session) -> Bool in
                return Calendar.current.isDate(session.startedAt, inSameDayAs: day)
                
            }
        
            var breathTime = 0
            var mindfulTime = 0
            var avgRR: Double = 0
            var slouchTime = 0
            var postureTime = 0
            var breathGoal = 0
            var postureGaol = 0
            
            for session in daySessions {
                if session.kind == 0 || session.kind == 1 {
                    breathTime += session.duration
                    let (_, rr, _, mindful) = session.sumBreaths()
                    mindfulTime += mindful
                    avgRR += rr
                }
                
                if session.kind == 0 || session.kind == 2 {
                    postureTime += session.duration
                    let sum = session.sumSlouches()
                    slouchTime += sum.0
                }
                breathGoal = session.dailyBreathGoalMins
                postureGaol = session.dailyPostureGoalMin
            }
            
            let count = daySessions.count
            if count > 0 {
                avgRR /= Double(count)
            }
            
            let uprightTime = postureTime - slouchTime
            
            breathTimes.append((breathTime, mindfulTime, breathGoal * 60))
            avgRRs.append(avgRR)
            uprightTimes.append((postureTime, uprightTime, postureGaol * 60))
        }
        
        mindfulView.color = UIColor(hexString: "#3dd3ca")
        mindfulView.type = .stack
        mindfulView.stackData = breathTimes
        mindfulView.setNeedsDisplay()
        
        rrView.color = UIColor(hexString: "#3dd3ca")
        rrView.type = .bar
        rrView.barData = avgRRs
        rrView.setNeedsDisplay()
        
        uprightView.color = UIColor(hexString: "#9fd93f")
        uprightView.type = .stack
        uprightView.stackData = uprightTimes
        uprightView.setNeedsDisplay()
    }
    
    func renderPassiveData() {
        var eiRatios: [Double] = []
        var avgRRs: [Double] = []
        var uprightTimes: [WeeklyGraph.StackDataType] = []
        
        for week in 0...6 {
            let day = begin.adding(.day, value: week)
            
            let daySessions = passives.filter { (session) -> Bool in
                return Calendar.current.isDate(session.startedAt, inSameDayAs: day)
                
            }
            
            var eiRatio: Double = 0
            var avgRR: Double = 0
            var slouchTime = 0
            var postureTime = 0
            
            for session in daySessions {
                let (ei, rr) = session.sumEIRatio()
                eiRatio += ei
                avgRR += rr
                postureTime += session.duration
                slouchTime += session.sumSlouchTime()
            }
            
            let count = daySessions.count
            if count > 0 {
                eiRatio /= Double(count)
                avgRR /= Double(count)
            }
            
            let uprightTime = postureTime - slouchTime
            
            eiRatios.append(eiRatio)
            avgRRs.append(avgRR)
            uprightTimes.append((postureTime, uprightTime, 0))
        }
        
        mindfulView.color = UIColor(hexString: "#3dd3ca")
        mindfulView.type = .bar
        mindfulView.barData = avgRRs
        mindfulView.setNeedsDisplay()
        
        rrView.color = UIColor(hexString: "#3dd3ca")
        rrView.type = .bar
        rrView.barData = eiRatios
        rrView.setNeedsDisplay()
        
        uprightView.color = UIColor(hexString: "#9fd93f")
        uprightView.type = .stack
        uprightView.stackData = uprightTimes
        uprightView.setNeedsDisplay()
    }
}
