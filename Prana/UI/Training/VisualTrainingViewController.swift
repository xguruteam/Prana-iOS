//
//  VisualTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 4/6/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit
import Macaw

class VisualTrainingViewController: UIViewController {

    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var liveGraphView: LiveGraph!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblTimeRemaining: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: SVGView!
    @IBOutlet weak var lblPostureValue: UILabel!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var lblStatus4: UILabel!
    
    @IBOutlet weak var btnBreathSensitivityRadio1: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle1: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio2: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle2: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio3: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle3: UIButton!
    
    @IBOutlet weak var btnPostureSensitivityRadio1: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle1: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio2: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle2: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio3: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle3: UIButton!
    
    @IBOutlet weak var controlPanel: UIView!
    
    @IBOutlet weak var btnStart: UIButton!
    
    var isShowControls: Bool = true
    var isStarted: Bool = false
    var isTutorial = false
    
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
                lblStatus3.text = "Upright Posture: --% (- of - seconds)"
            }
            else {
                lblStatus3.text = "Upright Posture: \(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration) seconds)"
            }
        }
    }
    
    var uprightDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lblStatus3.text = "Upright Posture: --% (- of - seconds)"
            }
            else {
                lblStatus3.text = "Upright Posture: \(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration) seconds)"
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
    
    var timeRemaining: Int = 0 {
        didSet {
            lblTimeRemaining.text = styledTime(v: timeRemaining)
        }
    }
    
    func roundDouble(double: Double) -> Double {
        return double * 10.0 / 10.0
    }
    
    func styledTime(v: Int) -> String {
        let m = Int(v / 60)
        let s = v - m * 60
        
        return String(format: "%d:%02d", m, s)
    }
    
    var objVisual: VisualTrainingScene?
    
    override func viewDidLoad() {
        
        mindfulBreaths = -1
        targetRR = -1.0
        postureDuration = -1
        slouches = -1
        
        onBreathSensitivityChange(btnBreathSensitivityRadio2)
        onPostureSensitivityChange(btnPostureSensitivityRadio2)
        
        displayPostureAnimation(1)
        
        btnStart.isHidden = true
        
        lblPostureValue.isHidden = true
        controlPanel.isHidden = false
        
        isStarted = false
        isShowControls = true
        
        let scene = VisualTrainingScene(180)
        scene.visualDelegate = self
        
        scene.size = CGSize(width: gameView.bounds.size.height, height: gameView.bounds.size.width)
        scene.scaleMode = .aspectFill
        
        gameView.presentScene(scene)
        
        gameView.ignoresSiblingOrder = true
        
//        gameView.showsFPS = true
//        gameView.showsNodeCount = true
        
        objVisual = scene
        
        liveGraphView.objLive = objVisual?.objLive
        liveGraphView.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let y = touch.location(in: self.view).y
            if y > 40 && y < self.view.frame.size.height - controlPanel.frame.size.height - 8.0 && isStarted {
                showHideControls()
            }
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        //MARK: Landscape
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .landscapeViewControllerDidDismiss, object: nil)
        }
        //End: Landscape
    }
    
    @IBAction func onSetUpright(_ sender: Any) {
        objVisual!.setUpright()
        
//        if !isStarted {
//            btnStart.isHidden = false
//        }
//        btnStart.alpha = 1.0
//        btnStart.isEnabled = true
    }
    
    @IBAction func onBreathSensitivityChange(_ sender: UIButton) {
        let val = sender.tag
        
        btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal);
        case 2:
            btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objVisual?.setBreathSensitivity(val)
    }
    
    @IBAction func onPostureSensitivityChange(_ sender: UIButton) {
        let val = sender.tag
        
        btnPostureSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnPostureSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal);
        case 2:
            btnPostureSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnPostureSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objVisual?.setPostureSensitivity(val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        var frame = whichFrame
        
        imgPostureAnimation.fileName = "sit (\(frame))"
    }
    
    func showHideControls() {
        if isShowControls {
            isShowControls = false
            btnStart.isHidden = true
//            controlPanel.isHidden = true
        } else {
            isShowControls = true
            btnStart.isHidden = false
//            controlPanel.isHidden = false
        }
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        if (objVisual?._isUprightSet)! && !isStarted {
            objVisual?.startMode()
            
            isStarted = true
            
            btnStart.setTitle("END SESSION EARLY", for: .normal)
            
            showHideControls()
        } else if isStarted {
            self.onBack(btnBack)
        }
    }
}

extension VisualTrainingViewController: VisualDelegate {
    
    func visualUprightHasBeenSet() {
        DispatchQueue.main.async {
            if !self.isStarted {
                self.btnStart.isHidden = false
            }
        }
    }
    
    func visualPostureFrameCalculated(frameIndex: Int) {
        DispatchQueue.main.async {
            self.displayPostureAnimation(frameIndex ?? 1)
        }
    }

    func visualUprightTime(uprightPostureTime: Int, elapsedTime: Int) {
        DispatchQueue.main.async {
            self.postureDuration = elapsedTime
            self.uprightDuration = uprightPostureTime
        }
    }

    func visualNewTargetRateCalculated(rate: Double) {
        DispatchQueue.main.async {
            self.targetRR = rate
        }
    }

    func visualNewActualRateCalculated(rate: Double) {
        DispatchQueue.main.async {
            self.actualRR = rate
        }
    }

    func visualNewBreathDone(total: Int, mindful: Int) {
        DispatchQueue.main.async {
            self.breathCount = total
            self.mindfulBreaths = mindful
        }
    }

    func visualNewSlouches(slouches: Int) {
        DispatchQueue.main.async {
            self.slouches = slouches
        }
    }

    func visualOnBack() {
        self.onBack(btnBack)
    }
    
    func visualOnTimer(v: Int) {
        self.timeRemaining = v
    }
}