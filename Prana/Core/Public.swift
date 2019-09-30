//
//  Public.swift
//  Prana
//
//  Created by Guru on 9/16/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

//MARK: RoundNumber
func roundNumber(num:Double, dec:Double) -> Double {
    return round(num*dec)/dec
}

func roundNumber(_ num1: Double, _ dec1: Double) -> Double {
    return round(num1 * dec1) / dec1
}

func styledTime(v: Int) -> String {
    let m = Int(v / 60)
    let s = v - m * 60
    
    return String(format: "%d:%02d", m, s)
}

    
