//
//  Session.swift
//  Prana
//
//  Created by Luccas on 4/30/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

class Session {
    var startedAt: Date
    var kind: Int
    var duration: Int = 0
    var mindful: Int = 0
    var upright: Int = 0
    
    var slouches: [SlouchRecord] = []
    var breaths: [BreathRecord] = []
    
    init(startedAt: Date, kind: Int) {
        self.startedAt = startedAt
        self.kind = kind
    }
    
    func addSlouch(timeStamp: Int) {
        guard timeStamp > 0 else { return }
        self.slouches.append(SlouchRecord(timeStamp))
    }
    
    func addBreath(timeStamp: Int, isMindful: Bool) {
        guard timeStamp > 0 else { return }
        self.breaths.append(BreathRecord(timeStamp: timeStamp, isMindful: isMindful))
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


struct SlouchRecord {
    var timeStamp: Int = 0
    init(_ timeStamp: Int) {
        self.timeStamp = timeStamp
    }
}

struct BreathRecord {
    var timeStamp: Int = 0
    var isMindful: Bool = false
    
    init(timeStamp: Int, isMindful: Bool) {
        self.timeStamp = timeStamp
        self.isMindful = isMindful
    }
}
