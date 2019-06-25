//
//  Session.swift
//  Prana
//
//  Created by Luccas on 4/30/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

class TrainingSession: Codable {
    var startedAt: Date
    var type: Int // 0: Visual, 1: Buzzer
    var typeString: String {
        switch type {
        case 0:
            return "Visual Training"
        default:
            return "Buzzer Training"
        }
    }
    var kind: Int // 0: Breath & Posture, 1: Breath Only, 2: Posture Only
    var kindString: String {
        switch kind {
        case 0:
            return "Breathing with Posture"
        case 1:
            return "Breathing Only"
        default:
            return "Posture Only"
        }
    }
    var wearing: Int // 0: Lower Back, 1: Upper Chest
    var wearingString: String {
        switch wearing {
        case 0:
            return "Lower Back"
        default:
            return "Upper Chest"
        }
    }
    var pattern: Int
    var patternString: String {
        return patternNames[pattern].0
    }
    var duration: Int = 0
    
    var slouches: [SlouchRecord] = []
    var breaths: [BreathRecord] = []
    
    init(startedAt: Date, type: Int, kind: Int, pattern: Int, wearing: Int) {
        self.startedAt = startedAt
        self.kind = kind
        self.type = type
        self.pattern = pattern
        self.wearing = wearing
    }
    
    func addSlouch(timeStamp: Int, duration: Int) {
        guard timeStamp > 0, duration > 0 else { return }
        self.slouches.append(SlouchRecord(timeStamp: timeStamp, duration: duration))
    }
    
    func addBreath(timeStamp: Int, isMindful: Bool, respRate: Double, eiRatio: Double) {
        guard timeStamp > 0 else { return }
        self.breaths.append(BreathRecord(timeStamp: timeStamp, isMindful: isMindful, respRate: respRate, eiRatio: eiRatio))
    }
    
    func floorSessionDuration() {
        self.slouches = slouches.filter {
            return $0.timeStamp <= self.duration ? true : false
        }
        
        self.breaths = breaths.filter {
            return $0.timeStamp <= self.duration ? true : false
        }
    }
    
    var summary: String {
        var breathTime = 0
        var mindfulTime = 0
        var rrSum: Double = 0
        var sessionCount = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        if kind == 0 {
            breathTime += duration
            let sum = sumMindfulTime(breaths)
            mindfulTime += sum.0
            rrSum += sum.1
            
            postureTime += duration
            slouchTime += sumSlouchTime(slouches)
            sessionCount += 1
        } else if kind == 1 {
            breathTime += duration
            let sum = sumMindfulTime(breaths)
            mindfulTime += sum.0
            rrSum += sum.1
            sessionCount += 1
        } else {
            postureTime += duration
            slouchTime += sumSlouchTime(slouches)
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
        
        if kind == 0 {
            return """
            Training: \(kindString), \(duration / 60) Mins completed
            Mindful Breaths: \(mindfulPercent)%, Avg. RR: \(rrSum), \(patternString) pattern
            Upright Posture: \(uprightPercent)%, Slouches: \(slouches.count), Wearing: \(wearingString)
            """
        } else if kind == 1 {
            return """
            Training: \(kindString), \(duration / 60) Mins completed
            Mindful Breaths: \(mindfulPercent)%, Avg. RR: \(rrSum), \(patternString) pattern
            """
        }
        

        return """
        Training: \(kindString), \(duration / 60) Mins completed
        Upright Posture: \(uprightPercent)%, Slouches: \(slouches.count), Wearing: \(wearingString)
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
}


struct SlouchRecord: Codable {
    var timeStamp: Int = 0
    var duration: Int = 0
    init(timeStamp: Int, duration: Int) {
        self.timeStamp = timeStamp
        self.duration = duration
    }
}

struct BreathRecord: Codable {
    var timeStamp: Int = 0
    var isMindful: Bool = false
    var respRate: Double = 0
    var eiRatio: Double = 0
    
    init(timeStamp: Int, isMindful: Bool, respRate: Double, eiRatio: Double) {
        self.timeStamp = timeStamp
        self.isMindful = isMindful
        self.respRate = respRate
        self.eiRatio = eiRatio
    }
}
