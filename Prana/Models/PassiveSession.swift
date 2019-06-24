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
}
