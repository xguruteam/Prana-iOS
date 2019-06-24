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
    var kind: Int // 0: Breath & Posture, 1: Breath Only, 2: Posture Only
    var wearing: Int // 0: Lower Back, 1: Upper Chest
    var pattern: Int
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
