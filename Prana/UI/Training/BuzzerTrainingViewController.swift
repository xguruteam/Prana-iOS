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
    
    var isLiving = false
    
    var objLive: Live?
    var objBuzzer: Buzzer?
    var isTutorial = false
    var isCompleted = false
    
    var sessionWearing: Int = 0 // Lower Back, 1: Upper Chest
    var sessionDuration: Int = 0
    
    
    var timeRemaining: Int = 0 {
        didSet {
            lblTimeRemaining.text = "\(styledTime(v: timeRemaining))"
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            lblTargetRespirationRate.text = "Target Respiration Rate:\(targetRR) Actual:\(actualRR)"
        }
    }
    var actualRR: Double = 0 {
        didSet {
            lblTargetRespirationRate.text = "Target Respiration Rate:\(targetRR) Actual:\(actualRR)"
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
        
        timeRemaining = sessionDuration
        
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
        
        btnStartStop.isHidden = true
        displayPostureAnimation(1)
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
//            self.btnStartStop.isEnabled = false
//            self.btnStartStop.alpha = 0.5
            //            self.btnNext.isEnabled = true
        }
        else {
            startLiving()
        }
    }
    
    func uprightHasBeenSetHandler() {
        if objBuzzer?.hasUprightBeenSet == 0 {
            objBuzzer?.hasUprightBeenSet = 1
            DispatchQueue.main.async {
//                self.btnStartStop.isEnabled = true
//                self.btnStartStop.alpha = 1.0
                self.btnStartStop.isHidden = false
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
        btnStartStop.setTitle("Stop", for: .normal)
        objBuzzer?.startSession()
        btnBack.isHidden = true
    }
    
    func stopLiving() {
        isLiving = false
        btnStartStop.setTitle("Start", for: .normal)
        objBuzzer?.endSession()
        PranaDeviceManager.shared.stopGettingLiveData()
        btnBack.isHidden = false
        
//        if isTutorial {
//            objLive?.removeDelegate(self as! LiveDelegate)
//            let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialEndViewController")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
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
        }
    }
    
    func buzzerNewUprightTime(_ uprightTime: Int, ofElapsed elapsed: Int) {
        DispatchQueue.main.async {
            self.lblUprightPosture.text = "Upright Posture: \(Int(uprightTime*100/elapsed))% (\(uprightTime) of \(elapsed) seconds)"
        }
    }
    
    func buzzerNewSlouches(_ slouches: Int) {
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
        }
        print("Session Completed!")
    }
    
}
