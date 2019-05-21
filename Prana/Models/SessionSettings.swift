//
//  SessionSettings.swift
//  Prana
//
//  Created by Guru on 5/21/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

struct SessionSettings: Codable {
    var kind: Int = 0
    var type: Int = 0
    var duration: Int = 5
    var wearing: Int = 0
    var lastWearing: Int = 0
}
