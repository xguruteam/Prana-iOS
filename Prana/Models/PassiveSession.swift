//
//  PassiveSession.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

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
    
    init(startedAt: Date, wearing: Int) {
        self.startedAt = startedAt
        self.wearing = wearing
    }
    
    func addSlouch(timeStamp: Int, duration: Int) {
        guard timeStamp > 0, duration > 0 else { return }
        self.slouches.append(SlouchRecord(timeStamp: timeStamp, duration: duration))
    }
    
    func addBreath(timeStamp: Int, isMindful: Bool, respRate: Double, eiRatio: Double) {
        guard timeStamp > 0 else { return }
        self.breaths.append(BreathRecord(timeStamp: timeStamp, isMindful: isMindful, respRate: respRate, targetRate: 0, eiRatio: eiRatio))
    }
    
    func floorSessionDuration() {
        let duration = self.duration / 60 * 60
        self.duration = duration
        
        self.slouches = slouches.filter {
            return $0.timeStamp <= self.duration ? true : false
        }
        
        self.breaths = breaths.filter {
            return $0.timeStamp <= self.duration ? true : false
        }
    }
    
    var summary: String {
        var breathTime = 0
        var rrSum: Double = 0
        var sessionCount = 0
        
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        breathTime += duration
        let sum = sumEIRatio()
        rrSum += sum.1
        
        postureTime += duration
        slouchTime += sumSlouchTime()
        sessionCount += 1

        
        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        return """
        Passive Tracking: \(duration / 60) Mins completed
        Avg. RR : \(round(rrSum))
        Upright Posture: \(round(uprightPercent))%, Slouches: \(slouches.count), Wearing: \(wearingString)
        """
    }
    
    var postureSummary: String {
        var postureTime = 0
        var uprightTime = 0
        var slouchTime = 0
        
        postureTime += duration
        slouchTime += sumSlouchTime()

        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        
        uprightPercent = round(uprightPercent)
        
        return """
        Upright Posture: \(uprightPercent)% (\(uprightTime) of \(postureTime) seconds)
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
            avgRR = (avgRR / Double(breaths.count))
        }
        
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
