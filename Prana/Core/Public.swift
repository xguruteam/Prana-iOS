//
//  Public.swift
//  Prana
//
//  Created by Guru on 9/16/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

var currentStrainGaugeLowest: Double = 0;
var currentStrainGaugeHighest: Double = 0;
var currentStrainGaugeLowestNew: Double = 0;
var currentStrainGaugeHighestNew: Double = 0;
var currentStrainGaugeHighestPrev: Double = 0;

func resetBreathRange() {
    currentStrainGaugeLowest = 0
    currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003; //JULY 13:New1k
    currentStrainGaugeHighestPrev = currentStrainGaugeHighest;  //JULY 13:New1k
    currentStrainGaugeLowestNew = currentStrainGaugeLowest; //JULY 13:New1k
    currentStrainGaugeHighestNew = currentStrainGaugeHighest;    //JULY 13:New1k
}

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

func getPercent(_ child: Int, _ parent: Int) -> Float {
    let x = Float(child * 100)
    let y = x / Float(parent)
    
    return y
}

func roundFloat(_ value: Float, point: Int) -> Any {
    if point <= 0 {
        let per = Float(Int(value * Float(10 * 1))) / Float(10 * 1)
        return per
    }
    let per = Float(Int(value * Float(powf(10.0, Float(point))))) / Float(powf(10.0, Float(point)))
    if per == floorf(per) {
        return Int(per)
    }
    
    return per
}

