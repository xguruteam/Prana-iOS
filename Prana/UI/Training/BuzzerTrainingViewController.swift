//
//  BuzzerTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 4/6/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Macaw

class BuzzerTrainingViewController: UIViewController {

    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet weak var lblBuzzerReason: UILabel!
    
    @IBOutlet weak var lblMindfulBreaths: UILabel!
    @IBOutlet weak var lblTargetRespirationRate: UILabel!
    @IBOutlet weak var lblBreathingPattern: UILabel!
    
    @IBOutlet weak var breathSensitivityGroup: UIView!
    @IBOutlet weak var btnBreathSensitivityRadio1: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle1: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio2: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle2: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio3: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle3: UIButton!
    @IBOutlet weak var lblUprightPosture: UILabel!
    
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var lblSlouches: UILabel!
    @IBOutlet weak var lblWearing: UILabel!
    //    @IBOutlet weak var btnNext: UIBarButtonItem!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    
    @IBOutlet weak var postureSensitivityGroup: UIView!
    @IBOutlet weak var btnPostureSensitivityRadio1: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle1: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio2: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle2: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio3: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle3: UIButton!
    
    @IBOutlet weak var btnStartStop: UIButton!
    
    @IBOutlet weak var liveGraph: LiveGraph!
    @IBOutlet weak var lblPostureValue: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblBreathingLabel: UILabel!
    @IBOutlet weak var con1: NSLayoutConstraint!
    @IBOutlet weak var con2: NSLayoutConstraint!
    @IBOutlet weak var con3: NSLayoutConstraint!
    @IBOutlet weak var con4: NSLayoutConstraint!
    @IBOutlet weak var con5: NSLayoutConstraint!
    @IBOutlet weak var con6: NSLayoutConstraint!
    @IBOutlet weak var con7: NSLayoutConstraint!
    @IBOutlet weak var con8: NSLayoutConstraint!
    @IBOutlet weak var con9: NSLayoutConstraint!
    @IBOutlet weak var con10: NSLayoutConstraint!
    
    @IBOutlet weak var lblPostureLabel: UILabel!
    @IBOutlet weak var con11: NSLayoutConstraint!
    @IBOutlet weak var con12: NSLayoutConstraint!
    @IBOutlet weak var con13: NSLayoutConstraint!
    @IBOutlet weak var con14: NSLayoutConstraint!
    @IBOutlet weak var con15: NSLayoutConstraint!
    
    @IBOutlet weak var lblGuide: UILabel!
    @IBOutlet weak var btnHelp: UIButton!
    
    var isLiving = false
    
    var objLive: Live?
    var objBuzzer: Buzzer?
    var isTutorial = false
    var isCompleted = false
    
    var sessionWearing: Int = 0 // Lower Back, 1: Upper Chest
    var sessionDuration: Int = 0
    var sessionKind: Int = 0 // 0: Breathing and Posture, 1: Breathing Only, 2: Posture Only
    
    var mindfulBreaths: Int = 0
    var breathCount: Int = 0
    var uprightDuration: Int = 0
    
    var currentSessionObject: Session?
    
    var timeRemaining: Int = 0 {
        didSet {
            lblTimeRemaining.text = "\(styledTime(v: timeRemaining))"
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            lblTargetRespirationRate.text = "Target/Actual Respiration Rate:\(targetRR)/\(actualRR) bpm"
        }
    }
    var actualRR: Double = 0 {
        didSet {
            lblTargetRespirationRate.text = "Target/Actual Respiration Rate:\(targetRR)/\(actualRR) bpm"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    
    func initView() {
        
        let border1 = CALayer()
        border1.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border1.frame = CGRect(x: 0.0, y: breathSensitivityGroup.frame.height + 4.0, width: breathSensitivityGroup.frame.width, height: 1.0)
        
        breathSensitivityGroup.layer.addSublayer(border1)
        
        let border2 = CALayer()
        border2.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border2.frame = CGRect(x: 0.0, y: postureSensitivityGroup.frame.height + 4.0, width: postureSensitivityGroup.frame.width, height: 1.0)
        
        postureSensitivityGroup.layer.addSublayer(border2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timeRemaining = sessionDuration * 60
        
        objLive = Live()
        objLive?.appMode = 3
        objLive?.addDelegate(self)
        liveGraph.objLive = objLive
        
        targetRR = 0
        actualRR = 0
        
        isCompleted = false
        btnStartStop.isEnabled = true
        
        lblBuzzerReason.text = "Buzzer Reason:"
//        lblTimeRemaining.text = "_:__"
        
        lblMindfulBreaths.text = "Mindful Breaths:"
        lblTargetRespirationRate.text = "Target Respiration Rate:"
        lblBreathingPattern.text = "Breathing Pattern: SLOWING PATTERN"
        
        lblUprightPosture.text = "Upright Posture:"
        
        lblWearing.text = "Wearing: " + (sessionWearing == 0 ? "Lower Back" : "Upper Chest")
        
        
        objBuzzer = Buzzer(pattern: 0, subPattern: 5, duration: timeRemaining, live: objLive!)
        objBuzzer?.delegate = self
        
        setBreathSensitivity(val: 2)
        setPostureSensitivity(val: 2)
        
        PranaDeviceManager.shared.startGettingLiveData()
        
        initView()
        
        btnStartStop.setTitle("START SESSION", for: .normal)
        btnStartStop.isHidden = true
        displayPostureAnimation(1)
        lblGuide.isHidden = false
        
        
        if sessionKind == 1 {
            lblPostureLabel.isHidden = true
            imgPostureAnimation.isHidden = true
            lblUprightPosture.isHidden = true
            lblSlouches.isHidden = true
            lblWearing.isHidden = true
            btnUpright.isHidden = true
            postureSensitivityGroup.isHidden = true
            
            con11.constant = 300
            con12.constant = 30
            con13.constant = 10
            con14.priority = .required
            
            objBuzzer?.useBuzzerForPosture = 0
            objBuzzer?.buzzerTrainingForPostureOnly = 0
            uprightHasBeenSetHandler()
            lblGuide.isHidden = true
        }
        else if sessionKind == 2{
            lblBuzzerReason.isHidden = true
            liveGraph.isHidden = true
            lblBreathingLabel.isHidden = true
            lblMindfulBreaths.isHidden = true
            lblTargetRespirationRate.isHidden = true
            lblBreathingPattern.isHidden = true
            breathSensitivityGroup.isHidden = true
            con1.priority = .required
            con2.priority = .required
            con3.priority = .required
            con4.priority = .required
            con5.priority = .required
            con7.priority = .defaultLow
            con6.priority = .required
            con8.priority = .required
            con15.priority = .required
            con9.constant = 200
            con10.constant = 200
            objBuzzer?.useBuzzerForPosture = 1
            objBuzzer?.buzzerTrainingForPostureOnly = 1
        }
        else {
            objBuzzer?.useBuzzerForPosture = 1
            objBuzzer?.buzzerTrainingForPostureOnly = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        objLive?.removeDelegate(self as! LiveDelegate)
        stopLiving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onBack(_ sender: Any) {
        if isTutorial {
            if isCompleted {
                let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialEndViewController")
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            self.navigationController?.popViewController(animated: true)
            return
        }
        else {
            currentSessionObject?.floorSessionDuration()
            
            if let session = currentSessionObject {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                    dataController.addSessionRecord(session)
                }
            }
            

            self.dismiss(animated: true) {
                
            }
        }
    }
    
    @IBAction func onBreathingResponseChange(_ sender: UIButton) {
        setBreathSensitivity(val: sender.tag)
    }
    
    @IBAction func onPostureResponseChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    @IBAction func onSetUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
    }
    
    @IBAction func onStartStop(_ sender: Any) {
        if isLiving {
            stopLiving()
            isCompleted = true
            btnStartStop.isEnabled = false
            btnStartStop.setTitle("Session End", for: .normal)
            btnStartStop.isHidden = true
//            self.btnStartStop.isEnabled = false
//            self.btnStartStop.alpha = 0.5
            //            self.btnNext.isEnabled = true
        }
        else {
            startLiving()
            btnHelp.isHidden = true
        }
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        var text: [AttributedTextBlock] = [
            .header2("Buzzer Training Instructions for Breathing & Posture"),
            .list("Requires your conscious attention during the session time"),
            .list("Start inhaling on a single buzz (any time after the single buzz but before the exhale double buzz)"),
            .list("Start exhaling on a double buzz (any time after the double buzz but before the next inhale buzz)"),
            .list("Maintain your upright posture"),
            .list("A long single buzz means you are not following the breathing pattern, and a long double buzz means your posture is slouching"),
            .list("During the session, keep your body fairly still to help accuracy")
        ]
        
        if sessionKind == 1 {
            text = [
                .header2("Buzzer Training Instructions for Breathing only"),
                .list("Requires your conscious attention during the session time"),
                .list("Start inhaling on a single buzz (any time after the single buzz but before the exhale double buzz)"),
                .list("Start exhaling on a double buzz (any time after the double buzz but before the next inhale buzz)"),
                .list("A long single buzz means you are not following the breathing pattern"),
                .list("During the session, keep your body fairly still to help accuracy")
            ]
        }
        else if sessionKind == 2 {
            text = [
                .header2("Buzzer Training Instructions for Posture only"),
                .list("Can be done in background without your full attention"),
                .list("Maintain your upright posture"),
                .list("A long double buzz means your posture is slouching"),
            ]
        }
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
    
    func uprightHasBeenSetHandler() {
        if objBuzzer?.hasUprightBeenSet == 0 {
            objBuzzer?.hasUprightBeenSet = 1
            DispatchQueue.main.async {
//                self.btnStartStop.isEnabled = true
//                self.btnStartStop.alpha = 1.0
                self.btnStartStop.isHidden = false
                self.lblGuide.isHidden = true
            }
        }
    }

    func setBreathSensitivity(val: Int) {
        btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        btnPostureSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnPostureSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnPostureSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnPostureSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setPostureResponsiveness(val: val)
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
    
    func startLiving() {
        isLiving = true
        btnStartStop.setTitle("END SESSION EARLY", for: .normal)
        objBuzzer?.startSession()
        self.currentSessionObject = Session(startedAt: Date(), kind: sessionKind)
        btnBack.isHidden = true
        btnHelp.isHidden = true
    }
    
    func stopLiving() {
        isLiving = false
        btnStartStop.setTitle("START SESSION", for: .normal)
        objBuzzer?.endSession()
        PranaDeviceManager.shared.stopGettingLiveData()
        btnBack.isHidden = false
        btnHelp.isHidden = false
        
//        if isTutorial {
//            objLive?.removeDelegate(self as! LiveDelegate)
//            let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialEndViewController")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
    }
    
    func makeSessionObject() {
        var duration = sessionDuration * 60
        if sessionKind == 0 {
            if timeRemaining < duration, breathCount > 0 {
                if timeRemaining > 0 {
                    duration -= timeRemaining
                }
                
                let mindful = duration * mindfulBreaths / breathCount
                let upright = uprightDuration
                
                currentSessionObject?.duration = duration
                currentSessionObject?.mindful = mindful
                currentSessionObject?.upright = upright
            }
        }
        else if sessionKind == 1{
            if timeRemaining < duration, breathCount > 0 {
                if timeRemaining > 0 {
                    duration -= timeRemaining
                }
                
                let mindful = duration * mindfulBreaths / breathCount
                
                currentSessionObject?.duration = duration
                currentSessionObject?.mindful = mindful
                currentSessionObject?.upright = 0
            }
        }
        else {
            if timeRemaining < duration {
                if timeRemaining > 0 {
                    duration -= timeRemaining
                }
                
                let upright = uprightDuration
                
                currentSessionObject?.duration = duration
                currentSessionObject?.mindful = 0
                currentSessionObject?.upright = upright
            }
        }
    }
    
    func onComplete() {
        isCompleted = true
        stopLiving()
    }
    
    func styledTime(v: Int) -> String {
        let m = Int(v / 60)
        let s = v - m * 60
        
        return String(format: "%d:%02d", m, s)
    }
}

extension BuzzerTrainingViewController: LiveDelegate {
    func liveDebug(para1: String, para2: String, para3: String, para4: String) {
        
    }
    
    func liveNewBreathingCalculated() {
        
    }
    
    func liveNewPostureCalculated() {
        DispatchQueue.main.async {
            self.displayPostureAnimation(self.objLive?.whichPostureFrame ?? 1)
        }
    }
    
    func liveNewRespRateCaclculated() {
        
    }
    
    func liveDidUprightSet() {
        uprightHasBeenSetHandler()
    }
    
}

extension BuzzerTrainingViewController: BuzzerDelegate {
    func buzzerNewActualRR(actualRR: Double) {
        DispatchQueue.main.async {
            self.actualRR = actualRR
        }
    }
    
    func buzzerNewMindfulBreaths(_ mindfuls: Int, ofTotalBreaths totals: Int) {
        if breathCount < totals {
            let isMindful = ((mindfuls > mindfulBreaths) ? true : false)
            self.currentSessionObject?.addBreath(timeStamp: self.sessionDuration * 60 - self.timeRemaining, isMindful: isMindful)
        }
        mindfulBreaths = mindfuls
        breathCount = totals
        DispatchQueue.main.async {
            self.lblMindfulBreaths.text = "Mindful Breaths: \(Int(mindfuls*100/totals))% (\(mindfuls) of \(totals))"
        }
    }
    
    func buzzerNewBuzzerReason(_ reason: String) {
        DispatchQueue.main.async {
            self.lblBuzzerReason.text = "Buzzer Reason: " + reason
        }
    }
    
    func burzzerNewTargetRR(targetRR: Double) {
        DispatchQueue.main.async {
            self.targetRR = targetRR
        }
    }
    
    func buzzerTimeElapsed(_ elapsed: Int) {
        DispatchQueue.main.async {
            self.timeRemaining = elapsed
            if elapsed % 60 == 0 {
                self.makeSessionObject()
            }
        }
    }
    
    func buzzerNewUprightTime(_ uprightTime: Int, ofElapsed elapsed: Int) {
        uprightDuration = uprightTime
        DispatchQueue.main.async {
            self.lblUprightPosture.text = "Upright Posture: \(Int(uprightTime*100/elapsed))% (\(uprightTime) of \(elapsed) s)"
        }
    }
    
    func buzzerNewSlouches(_ slouches: Int) {
        self.currentSessionObject?.addSlouch(timeStamp: self.sessionDuration * 60 - self.timeRemaining)
        DispatchQueue.main.async {
            self.lblSlouches.text = "Slouches: \(slouches)"
        }
    }
    
    func buzzerDidSessionComplete() {
        DispatchQueue.main.async {
            self.onComplete()
            self.btnStartStop.isEnabled = false
//            self.btnStartStop.alpha = 0.5
            self.btnStartStop.setTitle("Session Completed!", for: .normal)
//            self.btnNext.isEnabled = true
            self.btnStartStop.isHidden = true
        }
        print("Session Completed!")
    }
    
}
