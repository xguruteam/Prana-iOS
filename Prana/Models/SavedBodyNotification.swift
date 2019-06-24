//
//  SavedBodyNotification.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

struct SavedBodyNotification: Codable {
    var settings: [BodyNotification]
    
    init() {
        settings = []
        settings.append(BodyNotification())
        settings.append(BodyNotification())
        settings.append(BodyNotification())
    }
}

struct BodyNotification: Codable {
    var interval: Int = 0
    var isOn: [Bool] = Array(repeating: false, count: 13)
}
