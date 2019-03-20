//
//  BuzzerTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 3/19/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BuzzerTrainingViewController: UIViewController {

    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet weak var lblBuzzerReason: UILabel!
    @IBOutlet weak var lblMindfulBreaths: UILabel!
    @IBOutlet weak var lblTargetRespirationRate: UILabel!
    @IBOutlet weak var lblBreathingPattern: UILabel!
    @IBOutlet weak var lblUprightPosture: UILabel!
    @IBOutlet weak var lblSlouches: UILabel!
    @IBOutlet weak var lblWearing: UILabel!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    
    @IBOutlet weak var btnBreathSensitivity1: UIButton!
    @IBOutlet weak var btnBreathSensitivity2: UIButton!
    @IBOutlet weak var btnBreathSensitivity3: UIButton!
    @IBOutlet weak var btnPostureSensitivity1: UIButton!
    @IBOutlet weak var btnPostureSensitivity2: UIButton!
    @IBOutlet weak var btnPostureSensitivity3: UIButton!

    @IBOutlet weak var btnStartStop: UIButton!
    
    @IBOutlet weak var liveGraph: LiveGraph!
    
    var isLiving = false
    
    var objLive: Live?
    var objBuzzer: Buzzer?
    
    
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
        
        btnStartStop.isEnabled = false
        btnStartStop.alpha = 0.5

        // Do any additional setup after loading the view.
        objLive = Live()
        objLive?.addDelegate(self)
        liveGraph.objLive = objLive
        PranaDeviceManager.shared.startGettingLiveData()

        setBreathSensitivity(val: 1)
        setPostureSensitivity(val: 1)
        
        targetRR = 0
        actualRR = 0
        
        lblWearing.text = "LOWER BACK SEATED"
        
        lblBreathingPattern.text = "SLOWING PATTERN"
        lblUprightPosture.text = "Upright Posture: --"
        lblSlouches.text = "Slouches: 0"
        lblMindfulBreaths.text = "Mindful Breaths: __"
        lblBuzzerReason.text = "Buzzer Reason: __"
        
        lblTimeRemaining.text = "120"
        
        objBuzzer = Buzzer(pattern: 0, subPattern: 1, duration: 120, live: objLive!)
        objBuzzer?.delegate = self
        
        btnNext.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            objLive?.removeDelegate(self)
            stopLiving()
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
            self.btnStartStop.isEnabled = false
            self.btnStartStop.alpha = 0.5
            self.btnNext.isEnabled = true
        }
        else {
            startLiving()
        }
    }
    
    func uprightHasBeenSetHandler() {
        if objBuzzer?.hasUprightBeenSet == 0 {
            objBuzzer?.hasUprightBeenSet = 1
            DispatchQueue.main.async {
                self.btnStartStop.isEnabled = true
                self.btnStartStop.alpha = 1.0
            }
        }
    }
    
    func setBreathSensitivity(val: Int) {
        btnBreathSensitivity1.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
        btnBreathSensitivity2.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
        btnBreathSensitivity3.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
        
        switch val {
        case 1:
            btnBreathSensitivity1.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
        case 2:
            btnBreathSensitivity2.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
        case 3:
            btnBreathSensitivity3.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
        default:
            break
        }
        
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        btnPostureSensitivity1.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
        btnPostureSensitivity2.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
        btnPostureSensitivity3.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
        
        switch val {
        case 1:
            btnPostureSensitivity1.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
        case 2:
            btnPostureSensitivity2.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
        case 3:
            btnPostureSensitivity3.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
        default:
            break
        }
        
        objLive?.setPostureResponsiveness(val: val)
    }
    
    @objc func goNext() {
        
    }
    
    func startLiving() {
        isLiving = true
        btnStartStop.setTitle("Stop", for: .normal)
        objBuzzer?.startSession()
    }
    
    func stopLiving() {
        isLiving = false
        btnStartStop.setTitle("Start", for: .normal)
        objBuzzer?.endSession()
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BuzzerTrainingViewController: LiveDelegate {
    func liveNewBreathingCalculated() {
        
    }
    
    func liveNewPostureCalculated() {
        print("posture frame: \(objLive?.whichPostureFrame)")
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
            self.lblMindfulBreaths.text = "Mindful Breaths: \(mindfuls) of \(totals)"
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
            self.lblTimeRemaining.text = "\(elapsed)"
        }
    }
    
    func buzzerNewUprightTime(_ uprightTime: Int, ofElapsed elapsed: Int) {
        DispatchQueue.main.async {
            self.lblUprightPosture.text = "Upright Posture: \(uprightTime) of \(elapsed) seconds"
        }
    }
    
    func buzzerNewSlouches(_ slouches: Int) {
        DispatchQueue.main.async {
            self.lblSlouches.text = "Slouches: \(slouches)"
        }
    }
    
    func buzzerDidSessionComplete() {
        DispatchQueue.main.async {
            self.btnStartStop.isEnabled = false
            self.btnStartStop.alpha = 0.5
            self.btnStartStop.setTitle("Session Completed!", for: .normal)
            self.btnNext.isEnabled = true
        }
        stopLiving()
        print("Session Completed!")
    }
    
    
}
