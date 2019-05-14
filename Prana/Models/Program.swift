//
//  Program.swift
//  Prana
//
//  Created by Luccas on 5/8/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

class Program {
    var type: ProgramType
    var startedAt: Date
    var endedAt: Date?
    var status: String
    
    init(type: ProgramType) {
        self.type = type
        self.startedAt = Date()
        self.status = "inprogress"
    }
}

let fourteenGoals: [(Int, Int, Int)] = [
    (5, 10, 0),
    (5, 10, 1),
    (6, 15, 0),
    (6, 15, 1),
    (7, 20, 0),
    (7, 20, 1),
    (9, 25, 0),
    (9, 25, 1),
    (11, 30, 0),
    (11, 30, 1),
    (13, 35, 0),
    (13, 35, 1),
    (15, 40, 0),
    (15, 40, 1)
]

enum ProgramType {
    case fourteen
    case custom
    
    init?(from: String?) {
        switch from {
        case "14day":
            self = .fourteen
            return
        case "custom":
            self = .custom
            return
        default:
            break
        }
        return nil
    }
    
    func toString() -> String? {
        switch self {
        case .fourteen:
            return "14day"
        case .custom:
            return "custom"
        default:
            return nil
        }
    }
}
