//
//  Measurement.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

class Measurement: Codable {
    var date: Date
    var note: String?
    var data: [BMPosition: Float]
    
    init(date: Date, note: String?, data: [BMPosition: Float]) {
        self.date = date
        self.note = note
        self.data = data
    }
}

enum BMPosition: String, Codable {
    case neck = "NECK"
    case shoulders = "SHOULDERS"
    case chest = "CHEST"
    case waist = "WAIST"
    case hips = "HIPS"
    case larm = "L ARM"
    case lfarm = "L FOREARM"
    case lwrist = "L WRIST"
    case rarm = "R ARM"
    case rfarm = "R FOREARM"
    case rwrist = "R WRIST"
    case lthigh = "L THIGH"
    case lcalf = "L CALF"
    case rthigh = "R THIGH"
    case rcalf = "R CALF"
    case custom1 = "CUSTOM 1"
    case custom2 = "CUSTOM 2"
    case custom3 = "CUSTOM 3"
}
