//
//  Session.swift
//  Prana
//
//  Created by Luccas on 4/30/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

struct Session {
    var duration: Int
    var kind: Int
    var mindful: Int
    var upright: Int
    
    init(duration: Int, kind: Int, mindful: Int, upright: Int) {
        self.duration = duration
        self.kind = kind
        self.mindful = mindful
        self.upright = upright
    }
}
