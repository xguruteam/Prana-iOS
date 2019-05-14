//
//  SavedPattern.swift
//  Prana
//
//  Created by Luccas on 5/13/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

struct SavedPattern: Codable {
    var type: Int = 0
    
    var sub: Int = 0
    
    var startResp: Int = 0
    var minResp: Int = 0
    var ratio: Float = 1
    
    var inhalationTime: Float = 0.5
    var exhalationTime: Float = 0.5
    var retentionTime: Float = 0.5
    var timeBetweenBreaths: Float = 0.5
    
    init(type: Int) {
        self.type = type
    }
}
