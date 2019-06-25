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
        
        breathTime += duration
        let sum = sumMindfulTime(breaths)
        mindfulTime += sum.0
        rrSum += sum.1
        
        postureTime += duration
        slouchTime += sumSlouchTime(slouches)
        sessionCount += 1

        
        uprightTime = postureTime - slouchTime
        
        var uprightPercent: Float = 0
        if (postureTime > 0) {
            uprightPercent = getPercent(uprightTime, postureTime)
        }
        
        return """
        Passive Tracking: \(duration / 60) Mins completed
        Avg. RR : \(rrSum)
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
