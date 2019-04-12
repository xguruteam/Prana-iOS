//
//  VisualTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 3/21/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import GameplayKit
import SpriteKit

class VisualTrainingViewController1: UIViewController {
    
    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var liveGraphView: LiveGraph!
    
    @IBOutlet weak var lblPostureValue: UILabel!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var lblStatus4: UILabel!
    
    @IBOutlet weak var btnBS1: UIButton!
    @IBOutlet weak var btnBS2: UIButton!
    @IBOutlet weak var btnBS3: UIButton!
    
    @IBOutlet weak var btnPS1: UIButton!
    @IBOutlet weak var btnPS2: UIButton!
    @IBOutlet weak var btnPS3: UIButton!
    
    @IBOutlet weak var controlPanel: UIView!
    
    @IBOutlet weak var btnStart: UIButton!
    
    var mindfulBreaths: Int = 0 {
        didSet {
            if mindfulBreaths < 0 {
                lblStatus1.text = "Mindful Breaths: --% (- of -)"
            }
            else {
                lblStatus1.text = "Mindful Breaths: \(Int(mindfulBreaths * 100 / breathCount))% (\(mindfulBreaths) of \(breathCount))"
            }
        }
    }
    
    var breathCount: Int = 0 {
        didSet {
            if mindfulBreaths < 0 {
                lblStatus1.text = "Mindful Breaths: --% (- of -)"
            }
            else {
                lblStatus1.text = "Mindful Breaths: \(Int(mindfulBreaths * 100 / breathCount))% (\(mindfulBreaths) of \(breathCount))"
            }
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            if targetRR < 0 {
                lblStatus2.text = "Target Respiration Rate: -- Actual: --"
            }
            else {
                lblStatus2.text = "Target Respiration Rate: \(roundDouble(double: targetRR)) Actual: \(roundDouble(double: actualRR))"
            }
        }
    }
    
    var actualRR: Double = 0 {
        didSet {
            if targetRR < 0 {
                lblStatus2.text = "Target Respiration Rate: -- Actual: --"
            }
            else {
                lblStatus2.text = "Target Respiration Rate: \(roundDouble(double: targetRR)) Actual: \(roundDouble(double: actualRR))"
            }
        }
    }
    
    var postureDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lblStatus3.text = "Upright Posture: --% (- of - seconds"
            }
            else {
                lblStatus3.text = "Upright Posture: \(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration) seconds"
            }
        }
    }
    
    var uprightDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lblStatus3.text = "Upright Posture: --% (- of - seconds"
            }
            else {
                lblStatus3.text = "Upright Posture: \(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration) seconds"
            }
        }
    }
    
    var slouches: Int = 0 {
        didSet {
            if slouches < 0 {
                lblStatus4.text = "Slouches: --"
            }
            else {
                lblStatus4.text = "Slouches: \(slouches)"
            }
        }
    }
    
    func roundDouble(double: Double) -> Double {
        return double * 10.0 / 10.0
    }
    
    var objVisual: VisualTrainingScene?
    
    override func viewDidLoad() {

        mindfulBreaths = -1
        targetRR = -1.0
        postureDuration = -1
        slouches = -1
        
        onBreathSensitivityChange(btnBS2)
        onPostureSensitivityChange(btnPS2)
        
        btnStart.alpha = 0.5
        btnStart.isEnabled = false
        
        controlPanel.isHidden = false
        
        let scene = VisualTrainingScene()
        scene.size = CGSize(width: gameView.bounds.size.height, height: gameView.bounds.size.width)
//        scene.visualDelegate = self
        scene.scaleMode = .aspectFill
        gameView.presentScene(scene)
        
        gameView.ignoresSiblingOrder = true
        
        gameView.showsFPS = true
        gameView.showsNodeCount = true
        
        objVisual = scene
        
        liveGraphView.objLive = objVisual?.objLive
    }
    
    func onBack() {
        //MARK: Landscape
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .landscapeViewControllerDidDismiss, object: nil)
        }
        //End: Landscape
    }
    
    @IBAction func onSetUpright(_ sender: Any) {
        objVisual!.setUpright()
        
        btnStart.alpha = 1.0
        btnStart.isEnabled = true
    }
    
    @IBAction func onBreathSensitivityChange(_ sender: UIButton) {
        let val = sender.tag
        btnBS1.alpha = 0.5
        btnBS2.alpha = 0.5
        btnBS3.alpha = 0.5
        sender.alpha = 1.0
        objVisual?.setBreathSensitivity(val)
    }
    
    @IBAction func onPostureSensitivityChange(_ sender: UIButton) {
        let val = sender.tag
        btnPS1.alpha = 0.5
        btnPS2.alpha = 0.5
        btnPS3.alpha = 0.5
        sender.alpha = 1.0
        objVisual?.setPostureSensitivity(val)
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        if (objVisual?._isUprightSet)! {
            objVisual?.startMode()
            
            btnStart.alpha = 0.5
            btnStart.isEnabled = false
        }
    }
}

//extension VisualTrainingViewController: VisualDelegate {
//    func visualPostureFrameCalculated(frameIndex: Int) {
//        DispatchQueue.main.async {
////            self.lblPostureValue.text = "\(frameIndex)"
//        }
//    }
//
//    func visualUprightTime(uprightPostureTime: Int, elapsedTime: Int) {
//        DispatchQueue.main.async {
//            self.postureDuration = elapsedTime
//            self.uprightDuration = uprightPostureTime
//        }
//    }
//
//    func visualNewTargetRateCalculated(rate: Double) {
//        DispatchQueue.main.async {
//            self.targetRR = rate
//        }
//    }
//
//    func visualNewActualRateCalculated(rate: Double) {
//        DispatchQueue.main.async {
//            self.actualRR = rate
//        }
//    }
//
//    func visualNewBreathDone(total: Int, mindful: Int) {
//        DispatchQueue.main.async {
//            self.breathCount = total
//            self.mindfulBreaths = mindful
//        }
//    }
//
//    func visualNewSlouches(slouches: Int) {
//        DispatchQueue.main.async {
//            self.slouches = slouches
//        }
//    }
//
//    func visualOnBack() {
//        self.onBack()
//    }
//}
