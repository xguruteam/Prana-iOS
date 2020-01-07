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
        if let index = patternNumbers.index(of: pattern) {
            return patternNames[index].0
        } else {
            return patternNames[0].0
        }
    }
    var duration: Int = 0
    
    var slouches: [SlouchRecord] = []
    var breaths: [BreathRecord] = []
    var judgedBreaths: [LiveBreath] = []
    var judgedPosture: [LivePosture] = []
    
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
            let sum = sumBreaths()
            mindfulTime = sum.3
            rrSum = sum.1
            mindfulCount = sum.2
            breathCount = sum.0
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
            let sum = sumBreaths()
            mindfulTime = sum.3
            rrSum = sum.1
            mindfulCount = sum.2
            breathCount = sum.0
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
    
    func sumBreaths() -> (Int, Double, Int, Int) {
        var breathCount = 0
        var avgRR: Double = 0
        var mindfulCount = 0
        var mindfulTime = 0
        
        var sumRR: Double = 0
        var lastTime: Double = 0
        
        for breath in judgedBreaths {
            breathCount += breath.actuals.count
            var last: Double = 0
            for core in breath.actuals {
                sumRR += core.rr
                last = core.it
            }
            
            if breath.breathStatus == 1 {
                mindfulCount += breath.actuals.count
                mindfulTime += Int(last - lastTime)
            }
            lastTime = last
        }
        
        if breathCount > 0 {
            avgRR = sumRR / Double(breathCount)
        }
        
        return (breathCount, avgRR, mindfulCount, mindfulTime)
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
        
        let postures = judgedPosture
        
        for i in 0 ..< postures.count {
            var slouchDuration = 0
            
            let posture = postures[i]
            guard posture.isGood == 0 else { continue }
            
            if i < postures.count - 1 {
                let next = postures[i + 1]
                slouchDuration = next.time - posture.time
            } else {
                slouchDuration = Int(duration) - posture.time
            }
            
            slouchTime += slouchDuration
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
