//
//  Session.swift
//  Prana
//
//  Created by Luccas on 3/1/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class Session: NSObject {
    var sessionType: Int = 0
    var elasped: Int = 0
    var startTime: Date = Date()
    var uprightScore: Float = 0
    var slouches: [Slouch] = []
    var position: Int = 0 // 0:Upper Chest, 1:Lower Back
    var mindfulScore: Float = 0
    var breathings: [Breathing] = []
    var pattern: Int = 0
    var avgRR: Float = 0
    
    func getDictionary() -> [String : Any] {
        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = "MM-dd-yyy HH:mm:ss"
        
        let totals = Int.random(in: 0 ... Int(Float(Float(elasped)/60.0/avgRR)))
        let dic: [String : Any] = [
            "type": sessionType,
            "train_type": "BreathingPosture",
            "train_method": "visual",
            "session_started_at": targetDateFormatter.string(from: startTime),
            "session_duration": elasped,
            "wear_position": position,
            "upright_posture_score": uprightScore,
            "slouches": Int.random(in: 0 ... 20),
            "slouches_at": slouches.map({ (slouch) -> Int in
                slouch.timeStamp
            }),
            "breathing_pattern": pattern,
            "total_breaths": totals,
            "mindful_breathing_score": mindfulScore,
            "breaths_list": breathings.map({ (breathing) -> [String: Any] in
                ["time_stamp": breathing.timeStamp,
                 "is_mindful": breathing.isMindful]
            }),
            "avg_rr": avgRR
            ]
        return dic
    }
}

class Slouch {
    var timeStamp: Int = 0
    init(_ timeStamp: Int) {
        self.timeStamp = timeStamp
    }
}

class Breathing {
    var timeStamp: Int = 0
    var isMindful: Bool = false
    
    init(_ timeStamp: Int) {
        self.timeStamp = timeStamp
    }
}
