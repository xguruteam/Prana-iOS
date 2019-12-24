//
//  BuzzerTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 4/6/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Macaw

class BuzzerTrainingViewController: SuperViewController {

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
    @IBOutlet weak var lblBuzzWhenUnmindful: UILabel!
    @IBOutlet weak var swBuzzWhenUnmindful: UISwitch!
    
    @IBOutlet weak var batteryView: BatteryStateView!
    
    var isLiving = false
    
    var objLive: Live?
    var isTutorial = false
    var isCompleted = false
    
    var sessionWearing: Int = 0 // Lower Back, 1: Upper Chest
    var sessionDuration: Int = 0
    var sessionKind: Int = 0 // 0: Breathing and Posture, 1: Breathing Only, 2: Posture Only
    
    var mindfulBreaths: Int = 0
    var breathCount: Int = 0
    var uprightDuration: Int = 0
    
    var currentSessionObject: TrainingSession?
    
    var whichPattern: Int = 0
    var subPattern: Int = 0
    var startSubPattern: Int = 5
    var maxSubPattern: Int = 8
    
    var patternTitle: String = ""
    
    var slouchStartSeconds: Int = 0
    
    var isFinished = false
    
    var timeRemaining: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblTimeRemaining.text = "\(styledTime(v: self.timeRemaining))"
            }
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblTargetRespirationRate.text = "Target/Real-time Respiration Rate: \(self.targetRR)/\(self.actualRR) bpm"
            }
        }
    }
    var actualRR: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblTargetRespirationRate.text = "Target/Real-time Respiration Rate: \(self.targetRR)/\(self.actualRR) bpm"
            }
        }
    }
    
    var buzzReasonText: String? {
        didSet {
            DispatchQueue.main.async {
                self.lblBuzzerReason.text = "Buzzer Reason: " + (self.buzzReasonText ?? "")
            }
        }
    }
    
    
    deinit {
        print("BuzzerTrainingViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        swBuzzWhenUnmindful.addTarget(self, action: #selector(onBuzzWhenUnmindfulChange(_:)), for: .valueChanged)
        
        if isTutorial {
            onHelp(self.btnHelp)
        }
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
        
        swBuzzWhenUnmindful.onTintColor = UIColor(hexString: "#2bb7b8")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFinished {
            return
        }
        
        let objLiveGraph = Live()
        objLive = objLiveGraph
        objLiveGraph.graphStartTime = 0;  //AUG 12th New
        
        objLiveGraph.appMode = 3
        objLiveGraph.addDelegate(self)
        liveGraph.objLive = objLiveGraph
        
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
        
        setBreathSensitivity(val: 1)
        
        objLiveGraph.smoothBreathingCoefBaseLevel = 0.15; //AUG 1st NEW
        objLiveGraph.reversalThreshold = 9; //AUG 1st NEW
        objLiveGraph.birdIncrements = 24; //AUG 1st NEW
        
        useBuzzerForPosture = 1;
        
        targetRR = 0
        actualRR = 0

        /*
        if (DC.objGame.trainingPosture == 1) {
            buzzerTrainingUI.postureType.text = "LOWER BACK SEATED";
        }
        else if (DC.objGame.trainingPosture == 2) {
            buzzerTrainingUI.postureType.text = "UPPER BACK SEATED";
        }
            
        else if (DC.objGame.trainingPosture == 3) {
            buzzerTrainingUI.postureType.text = "UPPER BACK STANDING";
        }
        
        var nameOfPattern:String;
        
        if (DC.objGame.whichPattern != 0) {
            
            nameOfPattern = DC.objGame.patternSequence[DC.objGame.whichPattern][0][4];
            
        }
            
        else {
            
            nameOfPattern = "SLOWING PATTERN";
        }
        
        buzzerTrainingUI.patternName.text = nameOfPattern;
        
        
        whichPattern = DC.objGame.whichPattern;
        subPattern = DC.objGame.subPattern;
        
        */
        
        inhalationTimeEnd = Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][0]) * 20.0)
        retentionTimeEnd = inhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][1]) * 20.0)
        exhalationTimeEnd = retentionTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][2]) * 20.0)
        timeBetweenBreathsEnd = exhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][3]) * 20.0)

        slouchesCount = 0;
        uprightPostureTime = 0;
        hasUprightBeenSet = 0;
        totalBreaths = 0;
        
        mindfulBreathsCount = 0;
        
        trainingDuration = sessionDuration * 60;
        gameSetTime = trainingDuration;
        
        
        isCompleted = false
        btnStartStop.isEnabled = true
        
        lblBuzzerReason.text = "Buzzer Reason:"
//        lblTimeRemaining.text = "_:__"
        
        lblMindfulBreaths.text = "Mindful Breaths:"
        lblTargetRespirationRate.text = "Target/Real-time Respiration Rate:"
        lblBreathingPattern.text = "Breathing Pattern: SLOWING PATTERN"
        
        lblUprightPosture.text = "Upright Posture:"
        
        lblWearing.text = "Wearing: " + (sessionWearing == 0 ? "Lower Back" : "Upper Chest")
        
        lblBreathingPattern.text = "Breathing Pattern: \(self.patternTitle)"
        
        
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
            
            useBuzzerForPosture = 0
            buzzerTrainingForPostureOnly = 0
            uprightHasBeenSetHandler()
            lblGuide.isHidden = true
            doWarningBuzzesforUnmindful = 1
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
            useBuzzerForPosture = 1
            buzzerTrainingForPostureOnly = 1
            doWarningBuzzesforUnmindful = 0
            lblBuzzWhenUnmindful.isHidden = true
            swBuzzWhenUnmindful.isHidden = true
        }
        else {
            useBuzzerForPosture = 1
            buzzerTrainingForPostureOnly = 0
            doWarningBuzzesforUnmindful = 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isFinished {
            return
        }
        
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
            onComplete()
            btnStartStop.isEnabled = false
            btnStartStop.alpha = 0.5
            btnStartStop.setTitle("Session Ended Early", for: .normal)
            btnStartStop.isHidden = false
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
//                self.btnStartStop.isEnabled = true
//                self.btnStartStop.alpha = 1.0
                self.btnStartStop.isHidden = false
                self.lblGuide.isHidden = true
            }
        }
    }

    func setBreathSensitivity(val: Int) {
        objLive?.setBreathingResponsiveness(val: val)
        
        btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
            objLive?.reversalThreshold = 9;
        case 2:
            btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
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
        dataController.sensitivities.btps = val - 1
        dataController.saveSettings()
        
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
        //addEventListener(Event.ENTER_FRAME, enterFrameHandler); May 19th, REMOVED THIS LINE
        isBuzzerTrainingActive = 1; // May 19th, ADDED THIS LINE
        //DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/5.33; //AUG 1st REMOVED
        //DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/5.33); //AUG 1st REMOVED
        
        objLiveGraph.graphStartTime = objLiveGraph.timeElapsed;  //AUG 12th New
        objLiveGraph.judgedBreaths = []; //AUG 12th NEW
        objLiveGraph.judgedPosture = []; //AUG 12th NEW
        objLiveGraph.actualBreathsWithinAPattern = [] //AUG 12th NEW
        postureSessionTime = 0; //AUG 12th NEW
        breathInterrupted = 0; //AUG 12th NEW
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
        objLive = nil
        
        btnBack.isHidden = false
        btnHelp.isHidden = false
        
        //removeEventListener(Event.ENTER_FRAME, enterFrameHandler);  May 19th, REMOVED THIS LINE
        isBuzzerTrainingActive = 0; //May 19th, ADDED THIS LINE
        
        objLive?.isBuzzing = 0;
        buzzCount = 0;
        cycles = 0;
        buzzReason = 0;
        prevPostureState = 0;
        breathsOnCurrentLevel = 0;
        goodBreaths = 0;
        
//        if isTutorial {
//            objLive?.removeDelegate(self as! LiveDelegate)
//            let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialEndViewController")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
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
    
    @objc func onBuzzWhenUnmindfulChange(_ sender: UISwitch) {
        doWarningBuzzesforUnmindful = sender.isOn ? 1 : 0
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        
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
        }
        
//        onBack(btnBack)
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
    
//    var whichPattern:Int = 0;
//    var subPattern:Int = 0;
    
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
    var mindfulBreathsCount:Int = 0;
    var gameSetTime:Int = 0;
    var prevPostureState:Int = 0;
    var enterFrameCount:Int = 0;
    
    var totalBreaths:Int = 0;
    
    var breathsOnCurrentLevel:Int = 0;
    var goodBreaths:Int = 0;
    
    var useBuzzerForPosture:Int = 1;
    
    var buzzerTrainingForPostureOnly:Int = 0; //****** May 8th 2019 changes
    
    var isBuzzerTrainingActive:Int = 0; // May 19th, ADDED THIS LINE
    
    var doWarningBuzzesforUnmindful:Int = 1; //JULY 13:New1p   Set this to 0 when on/off switch is off  to not buzz for warning buzzes when unmindful breathing, should be on by default
    
    var previousExpectedBreathStartTime:Double = 0; //AUG 12th NEW
    var previousExpectedBreathRR:Double = 0; //AUG 12th NEW
    var lastXForActualBreath:Double = 0; //AUG 12th NEW
    var lastYForActualBreath:Double = 0; //AUG 12th NEW
    var breathInterrupted:Int = 0; //AUG 12th NEW
    var postureSessionTime:Int = 0; //AUG 12th NEW
    
    func buildJudgedBreaths(_ breathStatus: Int) {
        
        guard let objLiveGraph = objLive else { return }
        
        if (objLiveGraph.actualBreathsWithinAPattern.count == 0) { //AUG 12th NEW
            
            objLiveGraph.actualBreathsWithinAPattern = [CoreBreath(it: previousExpectedBreathStartTime, rr: Double(breathStatus))]; //AUG 12th NEW  If user did not breathe at all during the target breath, create a breath with 0 RR
            
        }    //AUG 12th NEW
        
        
        if (objLiveGraph.judgedBreaths.count == 1) {
            
            objLiveGraph.judgedBreaths.append(
                LiveBreath(target: nil,
                           actuals: objLiveGraph.actualBreathsWithinAPattern,
                           breathStatus: breathStatus)); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem), this is for the first pattern breath in the training, which cannot yet have a target RR (since that can only come at the end of the breath)
            
        }
        else {
            
            objLiveGraph.judgedBreaths.append(
                LiveBreath(target: CoreBreath(it: previousExpectedBreathStartTime, rr: previousExpectedBreathRR),
                           actuals: objLiveGraph.actualBreathsWithinAPattern,
                           breathStatus: breathStatus)); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem)
            
        }
        
        previousExpectedBreathStartTime = roundNumber((objLiveGraph.timeElapsed-objLiveGraph.graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath
        if (timeBetweenBreathsEnd > 0) { //AUG 12th NEW
            previousExpectedBreathRR = roundNumber(Double(3600/timeBetweenBreathsEnd)/3,10); //AUG 12th NEW
        } //AUG 12th NEW
        
        objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW
    }
    
    func buzzerTrainingMainLoop() {
        
        guard isBuzzerTrainingActive == 1, let objLiveGraph = objLive else { return }
        
//        buzzerTrainingUI.status.text = String(breathTime) + "  " + String(numOfInhales) +  "  " + String(numOfExhales) + "  " + String(whichPattern) + "  " + String(subPattern) + "  " + String(breathsOnCurrentLevel);
        
        buzzerTimerHandler();
        
        actualRR = objLiveGraph.respRate // buzzerTrainingUI.actualRR.text = String(DC.objLiveGraph.respRate);
        
        totalElapsedTime+=1;  //May 19th, this does NOT seem to be used
        
        
        if (buzzCount > 0) {
            
            buzzCount-=1;
            
            if (buzzCount == 0) {
                objLiveGraph.isBuzzing = 0;
                objLiveGraph.dampingLevel = 0;
                objLiveGraph.postureAttenuatorLevel = 0;
            }
            
        }
        
        breathTime+=1;
        
        if (breathTime < 0) {
            
            if (buzzReason == 1) { //due to bad breathing
                
                if (breathTime == -53) { // May 19th, Changed from -160      so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
                    
                    if (doWarningBuzzesforUnmindful == 1) { //JULY 13:New1p
                        
                        PranaDeviceManager.shared.sendCommand("Buzz,1.2");
                        objLiveGraph.isBuzzing = 1; //JULY 13:New1p
                        buzzCount = 30; //JULY 13:New1p
                    } //JULY 13:New1p
                    
                    //isBuzzing = 1; //JULY 13:Change1p  REMOVED
                    //buzzCount = 30; //JULY 13:Change1p  REMOVED
                }
            }
                
            else if (buzzReason == 2) { //due to bad posture
                
                if (breathTime == -93) { // May 19th, Changed from -280         so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
                    PranaDeviceManager.shared.sendCommand("Buzz,1");
                    objLiveGraph.isBuzzing = 1;
                    buzzCount = 63; //May 19th changed from 190
                }
                
                if (breathTime == -63) { //May 19th, Changed from -190        so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
                    PranaDeviceManager.shared.sendCommand("Buzz,1");
                    
                }
            }
            return; // May 19th comment change, if breath was bad, breatTime is set to -30, and needs time to clear bad breath buzzer indicator before proceeding
        }
        
        if (buzzerTrainingForPostureOnly == 1) {
            if (objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {   //****** May 8th 2019 changes
                buzzReasonText = "Slouching Posture"// buzzerTrainingUI.buzzerReason.text = "Slouching Posture";    //****** May 8th 2019 changes
                badPosture();    //****** May 8th 2019 changes
            }   //****** May 8th 2019 changes
            return;  //****** May 8th 2019 changes
        }   //****** May 8th 2019 changes
        
        
        
        if (breathTime >= timeBetweenBreathsEnd) {
            
            cycles+=1;
            breathTime = 0;
            hasInhaled = 0;
            hasExhaled = 0;
            numOfInhales = 0;
            numOfExhales = 0;
            whenInhaled = 0;
            whenExhaled = 0;
            buzzReason = 0;
            
            if (cycles == 2) { //AUG 1st NEW
                objLiveGraph.breathTopExceededThreshold = 1; //AUG 1st NEW
                objLiveGraph.lightBreathsThreshold = 1; //AUG 1st NEW
                objLiveGraph.minBreathRange = objLiveGraph.fullBreathGraphHeight/5.33; //AUG 1st NEW
                objLiveGraph.minBreathRangeForStuck = (objLiveGraph.fullBreathGraphHeight/5.33); //AUG 1st NEW
                
                objLiveGraph.judgedBreaths.append(
                    LiveBreath(target: nil,
                               actuals: objLiveGraph.actualBreathsWithinAPattern,
                               breathStatus: -1)); //AUG 12th NEW the concat() here is to copy the array (to avoid possible reference problem),saving all non-judged breaths here during 15 second calibration
                objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW
                previousExpectedBreathStartTime = roundNumber((objLiveGraph.timeElapsed-objLiveGraph.graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath
                
                
            } //AUG 1st NEW
            
            if (cycles > 2) {
                
                buildJudgedBreaths(1); // AUG 12th NEW, since breath reached the end in BT, then must be a good breath (otherwise it would be interrupted by badBreath())
                
                if (objLiveGraph.judgedBreaths.count > 2) { //AUG 12th NEW
//                    drawBreathingGraph(); //AUG 12th NEW
                } //AUG 12th NEW
                
                mindfulBreathsCount+=1;
                
                if (whichPattern == 0) {
                    goodBreaths+=1; //For breath pattern 0, for keeping track of 4 out of 5 good breaths to advance or recede
                }
                
                DispatchQueue.main.async {
                    guard self.totalBreaths > 0 else { return }
                    self.lblMindfulBreaths.text = "Mindful Breaths: \(Int(self.mindfulBreathsCount*100/self.totalBreaths))% (\(self.mindfulBreathsCount) of \(self.totalBreaths))"
                }
                self.currentSessionObject?.addBreath(timeStamp: self.sessionDuration * 60 - self.timeRemaining, isMindful: true, respRate: actualRR, targetRate: targetRR, eiRatio: 0, oneMinuteRR: 0)
                //buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths); //AUG 1st changed
                
            }
            
            
            if (whichPattern != 0) {
                
                if (Pattern.patternSequence[whichPattern].count > 1) {
                    subPattern+=1;
                    
                    if (subPattern > Pattern.patternSequence[whichPattern].count - 1) {
                        subPattern = 0;
                    }
                }
            }
            
            
        }
        
        
        /* if (takenFirstBreath == 0 && (DC.objLiveGraph.bottomReversalFound == 1 || DC.objLiveGraph.breathEnding == 1)) {
         return; //don't start buzzer training until user finishes the breath they were in (if any), same after bad breath
         }
         else {
         takenFirstBreath = 1;
         
         } */
        
        
        if (breathTime == 0) {
            
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            
            if (breathInterrupted == 1) {
                breathInterrupted = 0;
                objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW  To erase any actual inhales occuring after a bad breath warning but before the start of the next breath
                previousExpectedBreathStartTime = roundNumber((objLiveGraph.timeElapsed-objLiveGraph.graphStartTime)+0.5,10); //AUG 12th NEW
            }
            
            inhalationTimeEnd = Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][0]) * 20.0)
            retentionTimeEnd = inhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][1]) * 20.0)
            exhalationTimeEnd = retentionTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][2]) * 20.0)
            timeBetweenBreathsEnd = exhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][3]) * 20.0)
            
            buzzReasonText = "" //buzzerTrainingUI.buzzerReason.text = "";
            
            if (timeBetweenBreathsEnd > 0) { //AUG 12th NEW
                targetRR = roundNumber(Double(3600/timeBetweenBreathsEnd)/3,10)//buzzerTrainingUI.targetRR.text = String(roundNumber((3600/timeBetweenBreathsEnd)/3,10)); //May 19th changed
            } //AUG 12th NEW
            
            objLiveGraph.isBuzzing = 1;
            buzzCount = 10; //May 19th changed from 30
            numOfInhales = 0;
            numOfExhales = 0;
            
            if (cycles >= 2) { //JULY
                
                totalBreaths+=1;
                
                if (whichPattern == 0) {
                    breathsOnCurrentLevel+=1;
                    
                    //if (breathsOnCurrentLevel == 6) {//JULY 13:Change1r REMOVED
                    //    breathsOnCurrentLevel = 1;//JULY 13:Change1r REMOVED
                    //goodBreaths = 0;        //JULY 13:Change1r REMOVED
                    //}            //JULY 13:Change1r REMOVED
                    
                    if (breathsOnCurrentLevel == 6) {
                        if (goodBreaths >= 4) {
                            subPattern+=1;
                            if (subPattern > maxSubPattern) { //may 8th  maxSubPattern is representing the minimum target respiration rate
                                subPattern = maxSubPattern;  //may 8th
                            }    //may 8th
                        }
                        else {
                            subPattern-=1;
                            if (subPattern < 3) {
                                subPattern = 3; //minimum is 15bmp for buzzer training
                            }
                        }
                        breathsOnCurrentLevel = 1; //JULY 13:NEW1r
                        goodBreaths = 0;     //JULY 13:NEW1r
                        
                    }
                    
                }
                
            }
            
            //buzzerTrainingUI.status0.text = "New Breath Start";
        }
        
        if (breathTime == inhalationTimeEnd) {
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            objLiveGraph.isBuzzing = 1;
            buzzCount = 10; //May 19th changed from 30
            
            
        }
        
        
        if (breathTime == exhalationTimeEnd) {
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            objLiveGraph.isBuzzing = 1;
            buzzCount = 14; //May 19th changed from 40
        }
        
        if (breathTime == exhalationTimeEnd + 6) { // May 19th, Changed from 20 to 6
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
        }
        
        if (cycles < 2) {
            return;
        }
        
        if (objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {
            buzzReasonText = "Slouching Posture"//buzzerTrainingUI.buzzerReason.text = "Slouching Posture";
            totalBreaths-=1; //necessary to return to previous count if posture was the cause
            breathsOnCurrentLevel-=1; //necessary to return to previous count if posture was the cause
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
        
        if (numOfInhales > 1) {
            buzzReasonText = "Multiple inhales"//buzzerTrainingUI.buzzerReason.text = "Multiple inhales";
            //buzzerTrainingUI.status0.text = "numOfInhales > 1";
            badBreath();
            return;
        }
        
        if (breathTime >= inhalationTimeEnd) {
            if (numOfInhales == 0) {
                buzzReasonText = "Inhalation late"//buzzerTrainingUI.buzzerReason.text = "Inhalation late";
                //buzzerTrainingUI.status0.text = "No inhale by inhalationTimeEnd";
                badBreath();
                return;
            }
        }
        
        if (breathTime < retentionTimeEnd) {
            if (numOfExhales > 0) {
                buzzReasonText = "Exhalation early"//buzzerTrainingUI.buzzerReason.text = "Exhalation early";
                //buzzerTrainingUI.status0.text = "Exhalation before retentionTimeEnd";
                badBreath();
                return;
            }
        }
        
        if (breathTime >= exhalationTimeEnd) {
            if (numOfExhales == 0) {
                buzzReasonText = "Exhalation late"//buzzerTrainingUI.buzzerReason.text = "Exhalation late";
                //buzzerTrainingUI.status0.text = "No exhalation by exhalationTimeEnd";
                badBreath();
                return;
            }
        }
    }
    
    func badBreath() {
        guard let objLiveGraph = objLive else { return }
        buildJudgedBreaths(0); //AUG 12th NEW
        
        if (objLiveGraph.judgedBreaths.count > 2) { //AUG 12th NEW
//            drawBreathingGraph(); //AUG 12th NEW
        } //AUG 12th NEW
        
        breathTime = -60;  //May 19th Changed to -60 from -180
        hasInhaled = 0;
        hasExhaled = 0;
        numOfInhales = 0;
        numOfExhales = 0;
        takenFirstBreath = 0;
        whenInhaled = 0;
        whenExhaled = 0;
        buzzReason = 1;
        breathInterrupted = 1; //AUG 12th NEW
        
        DispatchQueue.main.async {
            guard self.totalBreaths > 0 else { return }
            self.lblMindfulBreaths.text = "Mindful Breaths: \(Int(self.mindfulBreathsCount*100/self.totalBreaths))% (\(self.mindfulBreathsCount) of \(self.totalBreaths))"
        }
        self.currentSessionObject?.addBreath(timeStamp: self.sessionDuration * 60 - self.timeRemaining, isMindful: false, respRate: actualRR, targetRate: targetRR, eiRatio: 0, oneMinuteRR: 0)
//        buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths); //AUG 1st changed
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
        buzzReason = 2;
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
                self.currentSessionObject?.addSlouch(timeStamp: slouchStartSeconds, duration: slouchDuration)
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
            self.lblSlouches.text = "Slouches: " + String(self.slouchesCount);
            let elapsed = self.gameSetTime - self.trainingDuration
            guard elapsed > 0 else { return }
            self.lblUprightPosture.text = "Upright Posture: \(Int(self.uprightPostureTime*100/elapsed))% (\(self.uprightPostureTime) of \(elapsed) s)"
        }
//        buzzerTrainingUI.timeUpright.text = String(uprightPostureTime) + " of " + String(gameSetTime - trainingDuration);
//        buzzerTrainingUI.slouches.text = String(slouchesCount);
        
        prevPostureState = objLiveGraph.postureIsGood;
        
        
        
        if (trainingDuration == 0) {
            
//            buzzerTrainingUI.sessionCompleteIndicator.visible = true;
            
            clearBuzzerTraining();
            
            PranaDeviceManager.shared.sendCommand("Buzz,2.5");
            
            DispatchQueue.main.async { [unowned self] in
                self.onComplete()
                self.btnStartStop.isEnabled = false
                self.btnStartStop.alpha = 0.5
                self.btnStartStop.setTitle("Session Completed!", for: .normal)
                //            self.btnNext.isEnabled = true
                self.btnStartStop.isHidden = false
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
        breathsOnCurrentLevel = 0;
        goodBreaths = 0;
        
    }
}

extension BuzzerTrainingViewController: LiveDelegate {
    
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
