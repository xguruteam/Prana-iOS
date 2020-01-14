//
//  BuzzerTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 4/6/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Toaster

class BuzzerPostureOnlyTrainingViewController: BaseBuzzerTrainingViewController {

    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet weak var postureRadioGroup: RadioGroupButton!
    
    @IBOutlet weak var lblUprightPosture: UILabel!
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var lblSlouches: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    @IBOutlet weak var btnStartStop: UIButton!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var lblGuide: UILabel!
    
    @IBOutlet weak var batteryView: BatteryStateView!
    
    var isLiving = false
    
    var objLive: Live?

    var isCompleted = false
    
    var currentSessionObject: TrainingSession?
    var slouchStartSeconds: Int = 0
    
    var isFinished = false
    
    var timeRemaining: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblTimeRemaining.text = "\(styledTime(v: self.timeRemaining))"
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        PranaDeviceManager.shared.addDelegate(self)

        if isTutorial {
            onHelp(self.btnHelp)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        btnUpright.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        btnStartStop.applyButtonGradient(colors: [#colorLiteral(red: 0.2980392157, green: 0.8470588235, blue: 0.8509803922, alpha: 1), #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)], points: [0.0, 1.0])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        PranaDeviceManager.shared.removeDelegate(self)
        
        if isFinished {
            return
        }
        
        stopLiving()
        currentSessionObject = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
        }
    }
    
    func configure() {
        if isFinished {
            return
        }
    
        postureRadioGroup.delegate = self
        
        let objLiveGraph = Live()
        objLive = objLiveGraph
        objLiveGraph.graphStartTime = 0;  //AUG 12th New
        
        objLiveGraph.appMode = 3
        objLiveGraph.addDelegate(self)
        objLiveGraph.startMode(); //Need this here because user needs to be able set posture before timer starts!
        
        objLiveGraph.breathTopExceededThreshold = 0; //AUG 1st NEW
        objLiveGraph.lightBreathsThreshold = 0; //AUG 1st NEW
        objLiveGraph.minBreathRange = objLiveGraph.fullBreathGraphHeight/16; //AUG 1st
        objLiveGraph.minBreathRangeForStuck = (objLiveGraph.fullBreathGraphHeight/16); //AUG 1st
        
        switch dataController.sensitivities.btps {
        case 0:
            setPostureSensitivity(val: 1)
        case 1:
            setPostureSensitivity(val: 2)
        default:
            setPostureSensitivity(val: 3)
        }
        
        objLiveGraph.smoothBreathingCoefBaseLevel = 0.15; //AUG 1st NEW
        objLiveGraph.reversalThreshold = 9; //AUG 1st NEW
        objLiveGraph.birdIncrements = 24; //AUG 1st NEW
        
        useBuzzerForPosture = 1

        slouchesCount = 0
        uprightPostureTime = 0
        hasUprightBeenSet = 0
        
        trainingDuration = sessionDuration * 60;
        gameSetTime = trainingDuration;

        isCompleted = false
        btnStartStop.isEnabled = true

        btnStartStop.setTitle("START SESSION", for: .normal)
        btnStartStop.isHidden = true
        lblGuide.isHidden = false
        displayPostureAnimation(1)
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        if isTutorial {
            if isCompleted {
                let vc = Utils.getStoryboardWithIdentifier(name: "TutorialTraining", identifier: "TutorialEndViewController")
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
    
    
    @IBAction func onSetUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
    }
    
    @IBAction func onStartStop(_ sender: Any) {
        if isLiving {
            onComplete()
            btnStartStop.isEnabled = false
            btnStartStop.alpha = 0.5
            btnStartStop.setTitle("Session Ended Early", for: .normal)
            btnStartStop.isHidden = false
            lblGuide.isHidden = true
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
            .list("Start inhaling after you feel the first quick buzz"),
            .list("Start exhaling on a double buzz (any time after the double buzz but before the next inhale buzz)"),
            .list("Start exhaling after you feel the next quick buzz"),
            .list("When you feel a quick double-buzz, the breath is complete. Wait to inhale until the quick buzz again"),
            .list("Maintain your upright posture"),
            .list("A long single buzz means you are not following the breathing pattern, and a long double buzz means your posture is slouching"),
            .list("If you are inhaling or exhaling too soon (breathing faster), that is usually what triggers the buzz warning"),
            .list("During the session, keep your body fairly still to help accuracy"),
            .list("The first two breaths of the session are not evaluated (they are for calibration)"),
        ]
        
        if sessionKind == 1 {
            text = [
                .header2("Buzzer Training Instructions for Breathing only"),
                .list("Requires your conscious attention during the session time"),
                .list("Start inhaling after you feel the first quick buzz"),
                .list("Start exhaling after you feel the next quick buzz"),
                .list("When you feel a quick double-buzz, the breath is complete. Wait to inhale until the quick buzz again"),
                .list("A long single buzz means you are not following the breathing pattern"),
                .list("If you are inhaling or exhaling too soon (breathing faster), that is usually what triggers the buzz warning"),
                .list("During the session, keep your body fairly still to help accuracy"),
                .list("The first two breaths of the session are not evaluated (they are for calibration)"),
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
        if hasUprightBeenSet == 0 {
            hasUprightBeenSet = 1
            DispatchQueue.main.async {

                self.btnStartStop.isHidden = false
                self.lblGuide.isHidden = true
            }
        }
    }
    
    func setPostureSensitivity(val: Int) {
        postureRadioGroup.selectedIndex = val
    
        dataController.sensitivities.btps = val - 1
        dataController.saveSettings()
        
        objLive?.setPostureResponsiveness(val: val)
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
    
    func startLiving() {
        
        guard let objLiveGraph = objLive else { return }
        
        isLiving = true
        
        btnStartStop.setTitle("END SESSION EARLY", for: .normal)
        
        self.currentSessionObject = TrainingSession(startedAt: Date(), type: 1, kind: sessionKind, pattern: whichPattern, wearing: sessionWearing)
        
        btnBack.isHidden = true
        btnHelp.isHidden = true
        
        breathTime = -1;
        totalElapsedTime = 0;
        hasInhaled = 0;
        hasExhaled = 0;
        numOfInhales = 0;
        numOfExhales = 0;
        takenFirstBreath = 0;
        objLive?.isBuzzing = 0;
        buzzCount = 0;
        isBuzzerTrainingActive = 1; // May 19th, ADDED THIS LINE

        objLiveGraph.graphStartTime = objLiveGraph.timeElapsed;  //AUG 12th New
        objLiveGraph.judgedBreaths = []; //AUG 12th NEW
        objLiveGraph.judgedPosture = []; //AUG 12th NEW
        objLiveGraph.actualBreathsWithinAPattern = [] //AUG 12th NEW
        postureSessionTime = 0; //AUG 12th NEW

        objLiveGraph.judgedPosture.append(LivePosture(time: 0, isGood: objLiveGraph.postureIsGood)); //AUG 12th NEW  Record the initial posture state, NOTE: this array only records CHANGES in posture, not every second of posture state
    }
    
    func stopLiving() {
        isLiving = false
        
        btnStartStop.setTitle("START SESSION", for: .normal)
        
        objLive?.removeDelegate(self)
        objLive?.stopMode(reset: dataController.isAutoReset)
        if let live = objLive {
            currentSessionObject?.judgedBreaths = live.judgedBreaths
            currentSessionObject?.judgedPosture = live.judgedPosture
        }
        
        btnBack.isHidden = false
        btnHelp.isHidden = false
        
        isBuzzerTrainingActive = 0; //May 19th, ADDED THIS LINE
        
        objLive?.isBuzzing = 0;
        buzzCount = 0;
        cycles = 0;
        buzzReason = 0;
        prevPostureState = 0;
        
        objLive = nil
    }
    
    func makeSessionObject() {
        var duration = sessionDuration * 60
        
        if timeRemaining < duration {
            if timeRemaining > 0 {
                duration -= timeRemaining
            }
        }
        
        currentSessionObject?.duration = duration
    }

    @objc func appMovedToBackground() {
        print("Buzzer Posture Only: App moved to background!")
        closeTraining()
    }
    
    func closeTraining() {
        if isTutorial {
            onBack(btnBack)
            return
        }
        
        if !isCompleted {
            onComplete()
            self.btnStartStop.isEnabled = false
            self.btnStartStop.alpha = 0.5
            self.btnStartStop.setTitle("Session Ended Early", for: .normal)
            self.btnStartStop.isHidden = false
            self.lblGuide.isHidden = true
        }
    }
    
    func onComplete() {
        isCompleted = true
        makeSessionObject()
        stopLiving()
        
        if isTutorial == false {
            currentSessionObject?.floorSessionDuration()
            
            if let session = currentSessionObject, session.duration > 0 {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                    dataController.addRecord(training: session)
                }
                
                isFinished = true
                let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
                vc.type = .session
                vc.session = session
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        currentSessionObject = nil
    }

    
    var totalElapsedTime:Int = 0;  //(in 1/60 of a second, or 1/FPS movie frame rate)
    var breathTime:Int = -1;
    
    var inhalationTimeEnd:Int = 0;
    var retentionTimeEnd:Int = 0;
    var exhalationTimeEnd:Int = 0;
    var timeBetweenBreathsEnd:Int = 0;

    var hasInhaled:Int = 0;
    var hasExhaled:Int = 0;
    var numOfInhales:Int = 0;
    var numOfExhales:Int = 0;
    var whenExhaled:Int = 0;
    var whenInhaled:Int = 0;
    
    var buzzCount:Int = 0;
    
    var takenFirstBreath:Int = 0;
    
    var buzzReason:Int = 0;
    
    var cycles:Int = 0;
    
    var hasUprightBeenSet:Int = 0;
    var trainingDuration:Int = 0;
    var slouchesCount:Int = 0;
    var uprightPostureTime:Int = 0;
    var gameSetTime:Int = 0;
    var prevPostureState:Int = 0;
    var enterFrameCount:Int = 0;
    
    var useBuzzerForPosture:Int = 1;
    
    var buzzerTrainingForPostureOnly:Int = 0; //****** May 8th 2019 changes
    var isBuzzerTrainingActive:Int = 0; // May 19th, ADDED THIS LINE
    
    var breathInterrupted:Int = 0; //AUG 12th NEW
    var postureSessionTime:Int = 0; //AUG 12th NEW
    
    
    func buzzerTrainingMainLoop() {
        
        guard isBuzzerTrainingActive == 1, let objLiveGraph = objLive else { return }
        buzzerTimerHandler();
        
        totalElapsedTime+=1;  //May 19th, this does NOT seem to be used
        
        if (buzzCount > 0) {            
            buzzCount-=1;
            
            if (buzzCount == 0) {
                objLiveGraph.isBuzzing = 0;
                objLiveGraph.dampingLevel = 0;
                objLiveGraph.postureAttenuatorLevel = 0;
            }
            
        }
        
        if (cycles < 2) {
            return;
        }
        
        if (objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {

            badPosture();
            return;
        }
        
        if (objLiveGraph.bottomReversalFound == 1 && hasInhaled == 0) {
            hasInhaled = 1;
            hasExhaled = 0;
            numOfInhales+=1;
        }
        
        if (objLiveGraph.topReversalFound == 1 && hasExhaled == 0) {
            if (numOfInhales > 0) { //idea is that an inhale must have occured first (within the breath window). This helps prevent exhales carrying into the start of a breath after a bad breath.
                hasExhaled = 1;
                hasInhaled = 0;
                numOfExhales+=1;
            }
        }

    }

    func badPosture() {
        breathTime = -100;  //May 19th Changed to -100 from -300
        hasInhaled = 0;
        hasExhaled = 0;
        numOfInhales = 0;
        numOfExhales = 0;
        takenFirstBreath = 0;
        whenInhaled = 0;
        whenExhaled = 0;
        breathInterrupted = 1; //AUG 12th NEW
    }
    
    func buzzerTimerHandler() {
        guard let objLiveGraph = objLive else { return }
        enterFrameCount+=1;
        
        if (enterFrameCount < 20) {  // May 19th, changed to 20
            return;
        }
        
        enterFrameCount = 0;
        
        trainingDuration-=1;
        postureSessionTime+=1; //AUG 1st NEW (measured in seconds, int)
        
        timeRemaining = trainingDuration// buzzerTrainingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);
        
        
        if (objLiveGraph.postureIsGood == 1) {
            uprightPostureTime+=1;
            let slouchDuration = (self.sessionDuration * 60 - self.timeRemaining) - slouchStartSeconds
            if slouchDuration > 0 {
//                self.currentSessionObject?.addSlouch(timeStamp: slouchStartSeconds, duration: slouchDuration)
            }
            slouchStartSeconds = 0
        }
        
        if (prevPostureState == 1) {
            if (objLiveGraph.postureIsGood == 0) {
                slouchesCount+=1;
                slouchStartSeconds = self.sessionDuration * 60 - self.timeRemaining
            }
        }
        
        if objLiveGraph.judgedPosture.isEmpty {
            objLiveGraph.judgedPosture.append(LivePosture(time: postureSessionTime, isGood: objLiveGraph.postureIsGood)); //AUG 1st NEW Only recording the changes in posture, that's all you need to create the full posture graph
        }
        else if (objLiveGraph.postureIsGood != objLiveGraph.judgedPosture[objLiveGraph.judgedPosture.count-1].isGood) { //AUG 1st NEW
            objLiveGraph.judgedPosture.append(LivePosture(time: postureSessionTime, isGood: objLiveGraph.postureIsGood)); //AUG 1st NEW Only recording the changes in posture, that's all you need to create the full posture graph
        } //AUG 1st NEW
        
//        drawPostureGraph(); //AUG 1st NEW
        
        DispatchQueue.main.async {
            self.lblSlouches.text = " " + String(self.slouchesCount);
            let elapsed = self.gameSetTime - self.trainingDuration
            guard elapsed > 0 else { return }
            self.lblUprightPosture.text = "\(Int(self.uprightPostureTime*100/elapsed))% (\(self.uprightPostureTime) of \(elapsed)s)"
        }
        
        prevPostureState = objLiveGraph.postureIsGood;
        if (trainingDuration == 0) {
            clearBuzzerTraining();
            
            PranaDeviceManager.shared.sendCommand("Buzz,2.5");
            
            DispatchQueue.main.async { [unowned self] in
                self.onComplete()
                self.btnStartStop.isEnabled = false
                self.btnStartStop.alpha = 0.5
                self.btnStartStop.setTitle("Session Completed!", for: .normal)
                self.btnStartStop.isHidden = false
                self.lblGuide.isHidden = true
            }
            print("Session Completed!")
            
        }
    }
    
    func clearBuzzerTraining()  {
        objLive?.isBuzzing = 0;
        buzzCount = 0;
        cycles = 0;
        buzzReason = 0;
        prevPostureState = 0;
    }
}

extension BuzzerPostureOnlyTrainingViewController: RadioGroupButtonDelegate {
    func onSelectedIndex(index: Int, sender: RadioGroupButton) {
        setPostureSensitivity(val: index)
    }
}

extension BuzzerPostureOnlyTrainingViewController: LiveDelegate {
    
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        buzzerTrainingMainLoop()
        DispatchQueue.main.async {
            self.batteryView.progress = CGFloat(sensorData[6]) / 100.0
        }
    }
    
    func liveNew(postureFrame: Int) {
        DispatchQueue.main.async {
            self.displayPostureAnimation(postureFrame)
        }
    }
    
    func liveUprightHasBeenSet() {
        uprightHasBeenSetHandler()
    }
}

extension BuzzerPostureOnlyTrainingViewController: PranaDeviceManagerDelegate
{
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.closeTraining()
            self.batteryView.progress = 0
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
}
