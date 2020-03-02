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
    
    var judgedBreaths: [LiveBreath] = []
    var judgedPosture: [LivePosture] = []
    
    var dailyBreathGoalMins: Int = 0
    var dailyPostureGoalMin: Int = 0
    
    var avgRespRR: Double = 0.0
    
    init(startedAt: Date,
         type: Int,
         kind: Int,
         pattern: Int,
         wearing: Int,
         breathGoalMins: Int,
         postureGoalMins: Int) {
        self.startedAt = startedAt
        self.kind = kind
        self.type = type
        self.pattern = pattern
        self.wearing = wearing
        self.dailyBreathGoalMins = breathGoalMins
        self.dailyPostureGoalMin = postureGoalMins
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
//        var breathTime = 0
//        var mindfulTime = 0
        var breathCount = 0
        var mindfulCount = 0
        var rrSum: Double = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        var slouches = 0
        
        if kind == 0 || kind == 1 {
//            breathTime = duration
            let sum = sumBreaths()
//            mindfulTime = sum.3
            rrSum = sum.1
            mindfulCount = sum.2
            breathCount = sum.0
        }
        
        if kind == 0 || kind == 2 {
            postureTime += duration
            let sum = sumSlouches()
            slouchTime = sum.0
            slouches = sum.1
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
            Training: \(kindString), \(getMinutesDescription(for: duration)) Mins
            Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))%, Avg. RR: \(roundFloat(Float(rrSum), point: type == 0 ? 1 : 2))
            Pattern: \(patternString)
            Upright Posture: \(roundFloat(uprightPercent, point: 1))%, Slouches: \(slouches)
            Wearing: \(wearingString)
            """
        } else if kind == 1 {
            return """
            Training: \(kindString), \(getMinutesDescription(for: duration)) Mins
            Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))%, Avg. RR: \(roundFloat(Float(rrSum), point: 2))
            Pattern: \(patternString)
            """
        }
        

        return """
        Training: \(kindString), \(getMinutesDescription(for: duration)) Mins
        Upright Posture: \(roundFloat(uprightPercent, point: 1))%, Slouches: \(slouches)
        Wearing: \(wearingString)
        """
    }
    
    var breathingSummary: String {
//        var breathTime = 0
//        var mindfulTime = 0
        var breathCount = 0
        var rrSum: Double = 0
        var mindfulCount = 0
        
        if kind == 0 || kind == 1 {
//            breathTime = duration
            let sum = sumBreaths()
//            mindfulTime = sum.3
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
            Mindful Breaths: \(roundFloat(mindfulPercent, point: 1))% (\(mindfulCount) of \(breathCount))
            Avg. RR: \(roundFloat(Float(rrSum), point: type == 0 ? 1 : 2))
            Pattern: \(patternString)
            """
        }
        
        return ""
    }
    
    var postureSummary: String {
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        var slouches = 0
        
        if kind == 0 || kind == 2 {
            postureTime = duration
            let sum = sumSlouches()
            slouchTime = sum.0
            slouches = sum.1
        }
        
        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        
        if kind == 0 || kind == 2 {
            return """
            Upright Posture: \(roundFloat(uprightPercent, point: 1))% (\(getMinutesDescription(for: uprightTime)) of \(getMinutesDescription(for: postureTime)) Mins)
            Slouches: \(slouches)
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
            guard breath.breathStatus >= 0 else { continue }
            
            breathCount += 1 // breath.actuals.count
            var last: Double = 0
            for core in breath.actuals {
                last = core.it
            }
            
            if breath.breathStatus == 1 {
                mindfulCount += breath.actuals.count
                mindfulTime += Int(last - lastTime)
            }
            lastTime = last
        }
        
        avgRR = avgRespRR
        
        return (breathCount, avgRR, mindfulCount, mindfulTime)
    }
    
    func sumSlouches() -> (Int, Int) {
        var slouchTime = 0
        var slouches = 0
        
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
            slouches += 1
        }
        return (slouchTime, slouches)
    }
}
