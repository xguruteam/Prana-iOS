//
//  PassiveSession.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

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

class PassiveSession: Codable {
    var startedAt: Date
    var duration: Int = 0
    var wearing: Int
    var wearingString: String {
        switch wearing {
        case 0:
            return "Lower Back"
        default:
            return "Upper Chest"
        }
    }
    
    var slouches: [SlouchRecord] = []
    var breaths: [BreathRecord] = []
    
    var avgRespRR: Double = 0.0
    var avgEIRate: Double = 0.0
    
    init(startedAt: Date, wearing: Int) {
        self.startedAt = startedAt
        self.wearing = wearing
    }
    
    func addSlouch(timeStamp: Int, duration: Int) {
        guard timeStamp > 0, duration > 0 else { return }
        self.slouches.append(SlouchRecord(timeStamp: timeStamp, duration: duration))
    }
    
    func addBreath(timeStamp: Int, isMindful: Bool, respRate: Double, eiRatio: Double, oneMinuteRR: Double) {
        guard timeStamp > 0 else { return }
        self.breaths.append(BreathRecord(timeStamp: timeStamp, isMindful: isMindful, respRate: respRate, targetRate: 0, eiRatio: eiRatio, oneMinuteRR: oneMinuteRR))
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
        var rrSum: Double = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        let sum = sumEIRatio()
        rrSum = sum.1
        
        postureTime = duration
        slouchTime = sumSlouchTime()

        
        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        return """
        Passive Tracking: \(getMinutesDescription(for: duration)) Mins
        Session Avg. RR : \(roundFloat(Float(rrSum), point: 1))
        Upright Posture: \(roundFloat(uprightPercent, point: 1))%, Slouches: \(slouches.count)
        Wearing: \(wearingString)
        """
    }
    
    var breathSummary: String {
        var rrSum: Double = 0
        let sum = sumEIRatio()
        rrSum = sum.1

        return """
        Session Avg. RR : \(roundFloat(Float(rrSum), point: 1))
        """
    }
    
    var postureSummary: String {
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        postureTime = duration
        slouchTime = sumSlouchTime()

        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        
        return """
        Upright Posture: \(roundFloat(uprightPercent, point: 1))% (\(getMinutesDescription(for: uprightTime)) of \(getMinutesDescription(for: postureTime)) Mins)
        Slouches: \(slouches.count)
        Wearing: \(wearingString)
        """
    }
    
    func sumEIRatio() -> (Double, Double) {
        var avgEI: Double = 0
        var avgRR: Double = 0
        for i in 0..<breaths.count {
            let breath = breaths[i]
            avgEI += breath.eiRatio
            avgRR += breath.respRate
        }
        if breaths.count > 0 {
            avgEI = (avgEI / Double(breaths.count))
        }
        
        avgRR = avgRespRR
        avgEI = avgEIRate
        
        return (avgEI, avgRR)
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
