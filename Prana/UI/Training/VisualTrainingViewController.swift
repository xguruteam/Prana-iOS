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
    @IBOutlet weak var btnSetUpright: UIButton!
    
    @IBOutlet weak var lblTimeRemaining: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    @IBOutlet weak var lblPostureValue: UILabel!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblStatus5: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var lblStatus4: UILabel!
    @IBOutlet weak var lblStatus6: UILabel!
    
    @IBOutlet weak var btnBreathSensitivityRadio1: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle1: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio2: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle2: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio3: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle3: UIButton!
    
    @IBOutlet weak var postureSensetivityGroup: UIView!
    @IBOutlet weak var btnPostureSensitivityRadio1: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle1: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio2: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle2: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio3: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle3: UIButton!
    
    @IBOutlet weak var controlPanel: UIView!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
    var isShowControls: Bool = true
    var isShowButton = true
    var isStarted: Bool = false {
        didSet {
            self.btnHelp.isHidden = isStarted
            self.btnBack.isHidden = isStarted
        }
    }
    var isTutorial = false
    var isCompleted = false
    
    var sessionWearing: Int = 0 // Lower Back, 1: Upper Chest
    var sessionDuration: Int = 0
    var sessionKind: Int = 0 // 0: Breathing and Posture, 1: Breathing Only, 2: Posture Only
    
    var mindfulBreaths: Int = 0 {
        didSet {
            if mindfulBreaths < 0 {
                lblStatus1.text = "Mindful Breaths:"
            }
            else {
                lblStatus1.text = "Mindful Breaths: \(Int(mindfulBreaths * 100 / breathCount))% (\(mindfulBreaths) of \(breathCount))"
            }
        }
    }
    
    var breathCount: Int = 0 {
        didSet {
            if mindfulBreaths < 0 {
                lblStatus1.text = "Mindful Breaths:"
            }
            else {
                lblStatus1.text = "Mindful Breaths: \(Int(mindfulBreaths * 100 / breathCount))% (\(mindfulBreaths) of \(breathCount))"
            }
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            if targetRR < 0 {
                lblStatus2.text = "Target Respiration Rate:"
            }
            else {
                lblStatus2.text = "Target Respiration Rate: \(roundDouble(double: targetRR))"
            }
        }
    }
    
    var actualRR: Double = 0 {
        didSet {
            if targetRR < 0 {
                lblStatus5.text = "Actual:"
            }
            else {
                lblStatus5.text = "Actual: \(roundDouble(double: actualRR))"
            }
        }
    }
    
    var postureDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lblStatus3.text = "Upright Posture:"
            }
            else {
                lblStatus3.text = "Upright Posture: \(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration) seconds)"
            }
        }
    }
    
    var uprightDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lblStatus3.text = "Upright Posture:"
            }
            else {
                lblStatus3.text = "Upright Posture: \(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration) seconds)"
            }
        }
    }
    
    var slouches: Int = 0 {
        didSet {
            if slouches < 0 {
                lblStatus4.text = "Slouches:"
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
        
        super.viewDidLoad()
        
        mindfulBreaths = -1
        targetRR = -1.0
        actualRR = -1.0
        postureDuration = -1
        slouches = -1
        
        onBreathSensitivityChange(btnBreathSensitivityRadio2)
        onPostureSensitivityChange(btnPostureSensitivityRadio2)
        
        displayPostureAnimation(1)
        
        btnStart.isHidden = true
        
//        lblPostureValue.isHidden = true
        controlPanel.isHidden = false
        
        isStarted = false
        isShowControls = true
        isShowButton = false
        isCompleted = false
        
        let scene = VisualTrainingScene(sessionDuration * 60, isBreathingOnly: (sessionKind == 1 ? true : false))
        scene.visualDelegate = self
        
        scene.size = CGSize(width: gameView.bounds.size.height, height: gameView.bounds.size.width)
        scene.scaleMode = .aspectFill
        
        gameView.presentScene(scene)
        
        gameView.ignoresSiblingOrder = true
        
//        gameView.showsFPS = true
//        gameView.showsNodeCount = true
        
        objVisual = scene
        
        
        liveGraphView.objLive = objVisual?.objLive

        if sessionKind == 1 {
            imgPostureAnimation.isHidden = true
            lblStatus3.isHidden = true
            lblStatus4.isHidden = true
            postureSensetivityGroup.isHidden = true
            liveGraphView.isHidden = false
            btnSetUpright.isHidden = true
        }
        else if sessionKind == 2 {
        }
        else {
            liveGraphView.isHidden = true
        }
        
        lblStatus6.text = "Wearing: " + (sessionWearing == 0 ? "Lower Back" : "Upper Chest")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        
        if !isStarted {
            return
        }
        
        if let touch = touches.first {
            let y = touch.location(in: self.view).y
            if y > 40 && y < self.view.frame.size.height - controlPanel.frame.size.height - 8.0 {
                showHideStartButton()
            }
            
            if y > (self.view.frame.size.height - controlPanel.frame.size.height - 8.0) && y < (self.view.frame.size.height - 8.0) {
                showHideControls()
            }
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        if isCompleted {
            self.onEnd()
            return
        }
        
        objVisual?.stopSession()
        
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
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        var text: [AttributedTextBlock] = [
            .header2("Visual Training Instructions"),
            .list("Inhale to move the bird up"),
            .list("Exhale to move the bird down"),
            .list("Collect the flowers to follow the breathing pattern"),
            .list("Maintain your upright posture"),
            .list("During the session, keep your body fairly still to help accuracy"),
            .list("Don't worry if you don't get it perfect this first time")]
        
        if sessionKind == 1 {
            text = [
                .header2("Visual Training Instructions for Breathing Only"),
                .list("Inhale to move the bird up"),
                .list("Exhale to move the bird down"),
                .list("Collect the flowers to follow the breathing pattern"),
                .list("During the session, keep your body fairly still to help accuracy"),
                .list("Don't worry if you don't get it perfect this first time")
            ]
        }
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
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
        
        if sessionWearing == 0 {
            imgPostureAnimation.image = UIImage(named: "sit (\(frame))")
        }
        else {
            imgPostureAnimation.image = UIImage(named: "stand (\(frame))")
        }
    }
    
    func uprightHasBeenSetHandler() {
        if !self.isStarted && !self.isCompleted {
            if !self.isShowButton {
                self.showHideStartButton()
            }
        }
    }
    
    func showHideControls() {
        if isShowControls {
            isShowControls = false
//            btnStart.isHidden = true
            controlPanel.isHidden = true
        } else {
            isShowControls = true
//            btnStart.isHidden = false
            controlPanel.isHidden = false
        }
    }
    
    func showHideStartButton() {
        if isShowButton {
            isShowButton = false
            btnStart.isHidden = true
        }
        else {
            isShowButton = true
            btnStart.isHidden = false
        }
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        if (objVisual?._isUprightSet)! && !isStarted {
            objVisual?.startMode()
            
            isStarted = true
            
            btnStart.setTitle("END SESSION EARLY", for: .normal)
            
            showHideStartButton()
        } else if isStarted {
            objVisual?.stopSession()
            onComplete()
        }
    }
    
    func onEnd() {
        var duration = sessionDuration * 60
        if timeRemaining < duration, breathCount > 0 {
            if timeRemaining > 0 {
                duration -= timeRemaining
            }
            
            let mindful = duration * mindfulBreaths / breathCount
            let upright = uprightDuration
            
            let session = Session(duration: duration, kind: sessionKind, mindful: mindful, upright: upright)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                dataController.addSessionRecord(session)
            }
        }
        
        
        //MARK: Landscape
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .visualViewControllerEndSession, object: nil)
        }
        //End: Landscape
    }
    
    func onComplete() {
        isCompleted = true
        isStarted = false
        if !isShowControls {
            showHideControls()
        }
        
        if isShowButton {
           showHideStartButton()
        }
    }
}

extension VisualTrainingViewController: VisualDelegate {
    
    func visualUprightHasBeenSet() {
        DispatchQueue.main.async {
            self.uprightHasBeenSetHandler()
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

    func visualOnComplete() {
        DispatchQueue.main.async {
            self.onComplete()
        }
    }
    
    func visualOnTimer(v: Int) {
        DispatchQueue.main.async {
            self.timeRemaining = v
        }
    }
}
