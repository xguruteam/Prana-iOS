//
//  Session.swift
//  Prana
//
//  Created by Luccas on 4/30/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

func getPercent(_ child: Int, _ parent: Int) -> Float {
    let x = Float(child * 100)
    let y = x / Float(parent)
    
    return y
}

func roundFloat(_ value: Float, point: Int) -> Any {
    if point <= 0 {
        let per = Float(Int(value * Float(10 * 1))) / Float(10 * 1)
        return per
    }
    let per = Float(Int(value * Float(powf(10.0, Float(point))))) / Float(powf(10.0, Float(point)))
    if per == floorf(per) {
        return Int(per)
    }
    
    return per
}

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
        if let index = patternNumbers.index(of: pattern) {
            return patternNames[index].0
        } else {
            return patternNames[0].0
        }
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
    
    func addBreath(timeStamp: Int, isMindful: Bool, respRate: Double, targetRate: Double, eiRatio: Double, oneMinuteRR: Double) {
        guard timeStamp > 0 else { return }
        self.breaths.append(BreathRecord(timeStamp: timeStamp, isMindful: isMindful, respRate: respRate, targetRate: targetRate, eiRatio: eiRatio, oneMinuteRR: oneMinuteRR))
    }
    
    func floorSessionDuration() {
//        let duration = self.duration / 60 * 60
//        self.duration = duration
//        
//        self.slouches = slouches.filter {
//            return $0.timeStamp <= self.duration ? true : false
//        }
//        
//        self.breaths = breaths.filter {
//            return $0.timeStamp <= self.duration ? true : false
//        }
    }
    
    var summary: String {
        var breathTime = 0
        var mindfulTime = 0
        var breathCount = 0
        var mindfulCount = 0
        var rrSum: Double = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        if kind == 0 || kind == 1 {
            breathTime = duration
            let sum = sumMindfulTime()
            mindfulTime = sum.0
            rrSum = sum.1
            mindfulCount = sum.2
            breathCount = breaths.count
        }
        
        if kind == 0 || kind == 2 {
            postureTime += duration
            slouchTime += sumSlouchTime()
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
        
        
        if kind == 0 {
            return """
            Training: \(kindString), \(duration / 60) Mins completed
            Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))%, Avg. RR: \(roundFloat(Float(rrSum), point: 2))
            Pattern: \(patternString)
            Upright Posture: \(roundFloat(uprightPercent, point: 1))%, Slouches: \(slouches.count), Wearing: \(wearingString)
            """
        } else if kind == 1 {
            return """
            Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))%, Avg. RR: \(roundFloat(Float(rrSum), point: 2))
            Pattern: \(patternString)
            """
        }
        

        return """
        Training: \(kindString), \(duration / 60) Mins completed
        Upright Posture: \(roundFloat(uprightPercent, point: 1))%, Slouches: \(slouches.count), Wearing: \(wearingString)
        """
    }
    
    var breathingSummary: String {
        var breathTime = 0
        var mindfulTime = 0
        var breathCount = 0
        var rrSum: Double = 0
        var mindfulCount = 0
        
        if kind == 0 || kind == 1 {
            breathTime = duration
            let sum = sumMindfulTime()
            mindfulTime = sum.0
            rrSum = sum.1
            mindfulCount = sum.2
            breathCount = breaths.count
        }
        
        var mindfulPercent:Float = 0
        if breathCount > 0 {
            mindfulPercent = getPercent(mindfulCount, breathCount)
        }

        if kind == 0 || kind == 1 {
            return """
            Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))% (\(mindfulCount) of \(breaths.count))
            Avg. RR: \(roundFloat(Float(rrSum), point: 2))
            Pattern: \(patternString)
            """
        }
        
        return ""
    }
    
    var postureSummary: String {
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        if kind == 0 || kind == 2 {
            postureTime = duration
            slouchTime = sumSlouchTime()
        }
        
        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        
        if kind == 0 || kind == 2 {
            return """
            Upright Posture: \(roundFloat(uprightPercent, point: 1))% (\(uprightTime) of \(postureTime) seconds)
            Slouches: \(slouches.count)
            Wearing: \(wearingString)
            """
        }
        return ""
    }
    
    func sumMindfulTime() -> (Int, Double, Int) {
        var mindfulTime = 0
        var avgRR: Double = 0
        var mindfulCount = 0
        for i in 0..<breaths.count {
            let breath = breaths[i]
            if breath.isMindful {
                mindfulCount += 1
                if i == 0 {
                    mindfulTime += breath.timeStamp
                } else {
                    mindfulTime += (breath.timeStamp - breaths[i - 1].timeStamp)
                }
            }
            avgRR += breath.respRate
        }
        if breaths.count > 2 {
            avgRR = (avgRR / Double(breaths.count - 2))
        } else {
            avgRR = 0
        }
        
        return (mindfulTime, avgRR, mindfulCount)
    }
    
    func sumSlouchTime() -> Int {
        var slouchTime = 0
        for i in 0..<slouches.count {
            let slouch = slouches[i]
            slouchTime += slouch.duration
        }
        return slouchTime
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
    var targetRate: Double = 0
    var eiRatio: Double = 0
    var oneMinuteRR: Double = 0
    
    init(timeStamp: Int, isMindful: Bool, respRate: Double, targetRate: Double, eiRatio: Double, oneMinuteRR: Double) {
        self.timeStamp = timeStamp
        self.isMindful = isMindful
        self.respRate = respRate
        self.targetRate = targetRate
        self.eiRatio = eiRatio
        self.oneMinuteRR = oneMinuteRR
    }
}
