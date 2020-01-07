//
//  LiveBreath.swift
//  Prana
//
//  Created by Guru on 9/16/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

struct LiveBreath: Codable {
    var target: CoreBreath?
    var actuals: [CoreBreath]
    var breathStatus: Int
}

struct CoreBreath: Codable {
    // inhale time
    var it: Double
    // respiration rate
    var rr: Double
}
