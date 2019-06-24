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
