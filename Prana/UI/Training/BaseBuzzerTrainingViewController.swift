//
//  BaseBuzzerTrainingViewController.swift
//  Prana
//
//  Created by Shine Man on 12/30/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BaseBuzzerTrainingViewController: SuperViewController {
    
    var isTutorial = false
    var sessionWearing: Int = 0 // Lower Back, 1: Upper Chest
    var sessionDuration: Int = 0
    var sessionKind: Int = 0 // 0: Breathing and Posture, 1: Breathing Only, 2: Posture Only
    
    var whichPattern: Int = 0
    var subPattern: Int = 0
    var startSubPattern: Int = 5
    var maxSubPattern: Int = 8
    var patternTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
