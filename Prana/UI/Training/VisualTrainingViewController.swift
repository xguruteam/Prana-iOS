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
import Toaster

class VisualTrainingViewController: SuperViewController {

    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var liveGraphView: LiveGraph!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSetUpright: UIButton!
    
    @IBOutlet weak var lblTimeRemaining: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    @IBOutlet weak var lblPostureValue: UILabel!
    @IBOutlet weak var lbUprisePosture: UILabel!
    @IBOutlet weak var lbSlouches: UILabel!
    
    @IBOutlet weak var postureRadioGroup: RadioGroupButton!
    @IBOutlet weak var lbMindfulBreaths: UILabel!
    @IBOutlet weak var lbTrargetActual: UILabel!
    @IBOutlet weak var breathRadioGroup: RadioGroupButton!

    @IBOutlet weak var postureSensetivityGroup: UIStackView!
    @IBOutlet weak var controlPanel: UIView!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var batteryView: BatteryStateView!
    @IBOutlet weak var btnUpright: UIButton!
    
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
    
    var currentSessionObject: TrainingSession?
    
    var whichPattern: Int = 0
    var subPattern: Int = 0
    var skipCalibration: Int = 0
    var startSubPattern: Int = 0
    var maxSubPattern: Int = 0
    
    var patternTitle: String = ""
    
    var slouchStartSeconds: Int = 0
    
    var mindfulBreaths: Int = 0 {
        didSet {
            if mindfulBreaths < 0 {
                lbMindfulBreaths.text = "---"
            }
            else {
                lbMindfulBreaths.text = "\(Int(mindfulBreaths * 100 / breathCount))% (\(mindfulBreaths) of \(breathCount))"
            }
        }
    }
    
    var breathCount: Int = 0 {
        didSet {
            if mindfulBreaths < 0 {
                lbMindfulBreaths.text = "---"
            }
            else {
                lbMindfulBreaths.text = "\(Int(mindfulBreaths * 100 / breathCount))% (\(mindfulBreaths) of \(breathCount))"
            }
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            if targetRR < 0 {
                lbTrargetActual.text = "-- / --"
            }
            else {
                lbTrargetActual.text = "\(roundDouble(double: targetRR))/\(roundDouble(double: actualRR))"
            }
        }
    }
    
    var actualRR: Double = 0 {
        didSet {
            if targetRR < 0 {
                lbTrargetActual.text = "-- / --"
            }
            else {
                lbTrargetActual.text = "\(roundDouble(double: targetRR))/\(roundDouble(double: actualRR))"
            }
        }
    }
    
    var postureDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lbUprisePosture.text = "---"
            }
            else {
                lbUprisePosture.text = "\(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration)s)"
            }
        }
    }
    
    var uprightDuration: Int = 0 {
        didSet {
            if postureDuration < 0 {
                lbUprisePosture.text = "---"
            }
            else {
                lbUprisePosture.text = "\(Int(uprightDuration * 100 / postureDuration))% (\(uprightDuration) of \(postureDuration)s)"
            }
        }
    }
    
    var slouches: Int = 0 {
        didSet {
            if slouches < 0 {
                lbSlouches.text = "--"
            }
            else {
                lbSlouches.text = "\(slouches)"
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        PranaDeviceManager.shared.addDelegate(self)
        
        mindfulBreaths = -1
        targetRR = -1.0
        actualRR = -1.0
        postureDuration = -1
        slouches = -1
        
        btnStart.isHidden = true
        controlPanel.isHidden = false
        
        isStarted = false
        isShowControls = true
        isShowButton = false
        isCompleted = false
        
        let scene = VisualTrainingScene(sessionDuration * 60, isBreathingOnly: (sessionKind == 1 ? true : false))
        scene.whichPattern = whichPattern
        scene.subPattern = subPattern
        scene.skipCalibration = skipCalibration
        scene.isAutoReset = dataController.isAutoReset
        if skipCalibration == 1 {
            scene.initialMessage = "Breathe normally here to set your initial Average Breath Depth."
        } else {
            scene.initialMessage = "Breathe normally here to set your initial Target Respiration Rate."
        }
        scene.startSubPattern = startSubPattern
        scene.maxSubPattern = maxSubPattern
        scene.visualDelegate = self
        scene.patternName = "Breathing Pattern: \(patternTitle)"
        
        scene.size = CGSize(width: gameView.bounds.size.height, height: gameView.bounds.size.width)
        scene.scaleMode = .aspectFill
        
        gameView.presentScene(scene)
        
        gameView.ignoresSiblingOrder = true
        objVisual = scene
        
        liveGraphView.objLive = objVisual?.objLive

        if sessionKind == 1 {
            imgPostureAnimation.isHidden = true

            postureSensetivityGroup.isHidden = true
            liveGraphView.isHidden = false
            btnSetUpright.isHidden = true
        }
        else if sessionKind == 2 {
        }
        else {
            liveGraphView.isHidden = true
        }
        
        postureRadioGroup.delegate = self
        breathRadioGroup.delegate = self
        switch dataController.sensitivities.vtbr {
        case 0:
            setBreathSensitivityChange(val: 1)
        case 1:
            setBreathSensitivityChange(val: 2)
        default:
            setBreathSensitivityChange(val: 3)
        }
        
        switch dataController.sensitivities.vtps {
        case 0:
            setPostureSensitivityChange(val: 1)
        case 1:
            setPostureSensitivityChange(val: 2)
        default:
            setPostureSensitivityChange(val: 3)
        }
        
        displayPostureAnimation(1)
        
        // Do any additional setup after loading the view.
        if isTutorial {
            onHelp(self.btnHelp)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnUpright.isHighlighted = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PranaDeviceManager.shared.removeDelegate(self)
    }
   
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
        objVisual?.visualDelegate = nil
        objVisual = nil
        liveGraphView.objLive = nil
        //MARK: Landscape
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .landscapeViewControllerDidDismiss, object: nil)
        }
        //End: Landscape
    }
    
    @IBAction func onSetUpright(_ sender: Any) {
        objVisual!.setUpright()
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        var text: [AttributedTextBlock] = [
            .header2("Visual Training Instructions"),
            .list("Collect the flowers to follow the breathing pattern"),
            .list("Inhale to move the bird up"),
            .list("Exhale to move the bird down"),
            .list("Hold your breath when the flowers are flat"),
            .list("Maintain your upright posture"),
            .list("During the session, keep your body fairly still to help accuracy"),
            .list("Tap the center of the screen to end the session early"),
        ]
        
        if sessionKind == 1 {
            text = [
                .header2("Visual Training Instructions for Breathing Only"),
                .list("Collect the flowers to follow the breathing pattern"),
                .list("Inhale to move the bird up"),
                .list("Exhale to move the bird down"),
                .list("Hold your breath when the flowers are flat"),
                .list("During the session, keep your body fairly still to help accuracy"),
                .list("Tap the center of the screen to end the session early"),
            ]
        }
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
    
    func setBreathSensitivityChange(val: Int) {
        breathRadioGroup.selectedIndex = val
        dataController.sensitivities.vtbr = val - 1
        dataController.saveSettings()
        
        objVisual?.setBreathSensitivity(val)
    }
    
    func setPostureSensitivityChange(val: Int) {
        postureRadioGroup.selectedIndex = val
        dataController.sensitivities.vtps = val - 1
        dataController.saveSettings()
        
        objVisual?.setPostureSensitivity(val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        let frame = whichFrame
        
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
//        self.btnUpright.setTitle("SET UPRIGHT ✅", for: .normal)
    }
    
    func showHideControls() {
        if isShowControls {
            isShowControls = false
            controlPanel.isHidden = true
        } else {
            isShowControls = true
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
            self.currentSessionObject = TrainingSession(startedAt: Date(), type: 0, kind: sessionKind, pattern: whichPattern, wearing: sessionWearing, breathGoalMins: dataController.dailyBreathGoalMins, postureGoalMins: dataController.dailyPostureGoalMins)
            
            isStarted = true
            
            btnStart.setTitle("END SESSION EARLY", for: .normal)
            
            showHideStartButton()
        } else if isStarted {
            currentSessionObject?.judgedBreaths = objVisual?.objLive?.judgedBreaths ?? []
            currentSessionObject?.judgedPosture = objVisual?.objLive?.judgedPosture ?? []
            objVisual?.onStop()
            objVisual?.visualDelegate = nil
            objVisual = nil
            liveGraphView.objLive = nil
            onComplete()
        }
    }
    
    func onEnd() {
        //MARK: Landscape
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .visualViewControllerEndSession, object: nil)
        }
        //End: Landscape
    }
    
    @objc func appMovedToBackground() {
        print("Visual Training: App moved to background!")
        closeTraining()
    }
    
    func closeTraining() {
        if isTutorial {
            onBack(btnStart)
            return
        }
        
        if isCompleted {
            onBack(btnStart)
        }
        
        if isCompleted == false {
            currentSessionObject?.judgedBreaths = objVisual?.objLive?.judgedBreaths ?? []
            currentSessionObject?.judgedPosture = objVisual?.objLive?.judgedPosture ?? []
            objVisual?.stopSession()
            objVisual = nil
            objVisual?.visualDelegate = nil
            liveGraphView.objLive = nil
            onComplete()
            onBack(btnStart)
        }
    }
    
    func onComplete() {
        isStarted = false
        if !isShowControls {
            showHideControls()
        }
        
        if isShowButton {
           showHideStartButton()
        }
        
        if isTutorial == false {
            currentSessionObject?.floorSessionDuration()
            
            if let session = currentSessionObject, session.duration >= 60 {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                    dataController.addRecord(training: session)
                    isCompleted = true
                }
            }
        } else {
            isCompleted = true
        }
        currentSessionObject = nil
    }
    
    func makeSessionObject() {
        var duration = sessionDuration * 60
        if timeRemaining < duration, breathCount > 0 {
            if timeRemaining > 0 {
                duration -= timeRemaining
            }
            
            currentSessionObject?.duration = duration
        }
    }
}

extension VisualTrainingViewController: RadioGroupButtonDelegate {
    func onSelectedIndex(index: Int, sender: RadioGroupButton) {
        if sender.tag == 1 {
            setBreathSensitivityChange(val: index)
        } else {
            setPostureSensitivityChange(val: index)
        }
    }
}

extension VisualTrainingViewController: VisualDelegate {
    func visualBattery(battery: Int) {
        DispatchQueue.main.async { [unowned self] in
            self.batteryView.progress = CGFloat(battery) / 100.0
        }
    }
    
    
    func visualUprightHasBeenSet() {
        DispatchQueue.main.async { [unowned self] in
            self.uprightHasBeenSetHandler()
        }
    }
    
    func visualPostureFrameCalculated(frameIndex: Int) {
        DispatchQueue.main.async { [unowned self] in
            self.displayPostureAnimation(frameIndex)
        }
    }

    func visualUprightTime(uprightPostureTime: Int, elapsedTime: Int) {
        if uprightDuration < uprightPostureTime {
            // end slouch
            let slouchDuration = (self.sessionDuration * 60 - self.timeRemaining) - slouchStartSeconds
            if slouchDuration > 0 {
//                self.currentSessionObject?.addSlouch(timeStamp: slouchStartSeconds, duration: slouchDuration)
            }
            slouchStartSeconds = 0
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.postureDuration = elapsedTime
            self.uprightDuration = uprightPostureTime
        }
    }

    func visualNewTargetRateCalculated(rate: Double) {
        DispatchQueue.main.async { [unowned self] in
            self.targetRR = rate
        }
    }

    func visualNewActualRateCalculated(rate: Double) {
        DispatchQueue.main.async { [unowned self] in
            self.actualRR = rate
        }
    }

    func visualNewBreathDone(total: Int, mindful: Int) {
        if breathCount < total {
            // new breath
//            let isMindful = (self.mindfulBreaths != mindful)
//            self.currentSessionObject?.addBreath(timeStamp: self.sessionDuration * 60 - self.timeRemaining, isMindful: isMindful, respRate: actualRR, targetRate: targetRR, eiRatio: 0, oneMinuteRR: 0)
        }
        DispatchQueue.main.async { [unowned self] in
            self.breathCount = total
            self.mindfulBreaths = mindful
        }
    }

    func visualNewSlouches(slouches: Int) {
        slouchStartSeconds = self.sessionDuration * 60 - self.timeRemaining
        
        DispatchQueue.main.async { [unowned self] in
            self.slouches = slouches
//            self.currentSessionObject?.addSlouch(timeStamp: self.sessionDuration * 60 - self.timeRemaining)
        }
    }

    func visualOnComplete() {
        currentSessionObject?.judgedBreaths = objVisual?.objLive?.judgedBreaths ?? []
        currentSessionObject?.judgedPosture = objVisual?.objLive?.judgedPosture ?? []
        DispatchQueue.main.async { [unowned self] in
            self.onComplete()
        }
    }
    
    func visualOnTimer(v: Int) {
        DispatchQueue.main.async { [unowned self] in
            self.timeRemaining = v
//            if v % 60 == 0 {
                self.makeSessionObject()
//            }
        }
    }
    
    func visualNewSessionAvgRRCalculated(rate: Double) {
        DispatchQueue.main.async { [unowned self] in
            self.currentSessionObject?.avgRespRR = rate
        }
    }
}

extension VisualTrainingViewController: PranaDeviceManagerDelegate
{
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async {
            self.closeTraining()
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
}
