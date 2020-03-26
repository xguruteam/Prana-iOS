//
//  BuzzerTrainingViewController.swift
//  Prana
//
//  Created by Luccas on 4/6/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Toaster

class BuzzerTrainingViewController: BaseBuzzerTrainingViewController {

    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet weak var lblBuzzerReason: UILabel!
    
    @IBOutlet weak var lblMindfulBreaths: UILabel!
    @IBOutlet weak var lblTargetRespirationRate: UILabel!
    @IBOutlet weak var lblBreathingPattern: UILabel!
    @IBOutlet weak var breathRadioGroup: RadioGroupButton!
    
    @IBOutlet weak var postureRadioGroup: RadioGroupButton!
    
    @IBOutlet weak var lblUprightPosture: UILabel!
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var lblSlouches: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
   
    @IBOutlet weak var btnStartStop: UIButton!
    
    @IBOutlet weak var liveGraph: LiveGraph!
    @IBOutlet weak var btnBack: UIButton!
    
   
    @IBOutlet weak var lblGuide: UILabel!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var lblBuzzWhenUnmindful: UILabel!
    @IBOutlet weak var swBuzzWhenUnmindful: UISwitch!
    
    @IBOutlet weak var batteryView: BatteryStateView!
    
    //For resoluton
    @IBOutlet weak var liveGraphHeight: NSLayoutConstraint!    
    @IBOutlet weak var bottoLabelSpace: NSLayoutConstraint!
    
    var isLiving = false
    
    var objLive: Live?
    var isCompleted = false

    var mindfulBreaths: Int = 0
    var breathCount: Int = 0
    var uprightDuration: Int = 0
    
    var currentSessionObject: TrainingSession?
    var slouchStartSeconds: Int = 0
    
    var isFinished = false
    
    var timeRemaining: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.lblTimeRemaining.text = "\(styledTime(v: self.timeRemaining))"
            }
        }
    }
    
    var targetRR: Double = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.lblTargetRespirationRate.text = "\(self.targetRR)/\(self.actualRR) bpm"
            }
        }
    }
    var actualRR: Double = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.lblTargetRespirationRate.text = "\(self.targetRR)/\(self.actualRR) bpm"
            }
        }
    }
    
    var buzzReasonText: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.lblBuzzerReason.text = " " + (self.buzzReasonText ?? "")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        swBuzzWhenUnmindful.addTarget(self, action: #selector(onBuzzWhenUnmindfulChange(_:)), for: .valueChanged)
        PranaDeviceManager.shared.addDelegate(self)
        adjustContraints()
        
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
//        btnUpright.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        btnUpright.isHighlighted = false
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
        
        breathRadioGroup.delegate = self
        postureRadioGroup.delegate = self
        
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

        lblBuzzerReason.text = ""
        lblBreathingPattern.text = " \(self.patternTitle)"
        btnStartStop.setTitle("START SESSION", for: .normal)
        btnStartStop.isHidden = true
        displayPostureAnimation(1)
        lblGuide.isHidden = false
    }
    
    func adjustContraints() {
        if UIScreen.main.nativeBounds.height >= 1920 { // above 8 plus
            liveGraphHeight.constant = 150
            bottoLabelSpace.constant = 40
        }
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
            .list("Start exhaling after you feel the next quick buzz"),
            .list("When you feel a quick double-buzz, the breath is complete. Wait to inhale until the quick buzz again"),
            .list("A long single buzz means you are not following the breathing pattern"),
            .list("If you are inhaling or exhaling too soon (breathing faster), that is usually what triggers the buzz warning"),
            .list("A long double buzz means you are slouching"),
            .list("During the session, keep your body fairly still to help accuracy"),
            .list("The first two breaths of the session are not evaluated (they are for calibration)"),
            .list("Buzzer training requires a little bit of practice to get used to, so don’t get discouraged if the first few sessions are challenging"),
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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.btnStartStop.isHidden = false
                self.lblGuide.isHidden = true
//                self.btnUpright.setTitle("SET UPRIGHT ✅", for: .normal)
            }
        }
    }

    func setBreathSensitivity(val: Int) {
        objLive?.setBreathingResponsiveness(val: val)
        
        breathRadioGroup.selectedIndex = val
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
        
        self.currentSessionObject = TrainingSession(startedAt: Date(), type: 1, kind: sessionKind, pattern: whichPattern, wearing: sessionWearing, breathGoalMins: dataController.dailyBreathGoalMins, postureGoalMins: dataController.dailyPostureGoalMins)
        
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
        
        btnBack.isHidden = false
        btnHelp.isHidden = false
        
        isBuzzerTrainingActive = 0; //May 19th, ADDED THIS LINE
        
        objLive?.isBuzzing = 0;
        buzzCount = 0;
        cycles = 0;
        buzzReason = 0;
        prevPostureState = 0;
        breathsOnCurrentLevel = 0;
        goodBreaths = 0;
        
        objLive = nil
        liveGraph.objLive = nil
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
        print("Buzzer Training: App moved to background!")
        closeTraining()
    }
    
    func closeTraining() {
        if isTutorial {
            onBack(btnBack)
            return
        }
        
        if !isCompleted {
            onComplete()
            lblGuide.isHidden = true
            self.btnStartStop.isEnabled = false
            self.btnStartStop.alpha = 0.5
            self.btnStartStop.setTitle("Session Ended Early", for: .normal)
            self.btnStartStop.isHidden = false
        }
    }
    
    func onComplete() {
        isCompleted = true
        makeSessionObject()
        stopLiving()
        
        if isTutorial == false {
            currentSessionObject?.floorSessionDuration()
            
            if let session = currentSessionObject, session.duration >= 60 {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                    dataController.addRecord(training: session)
                }
                
                isFinished = true
                let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
                vc.type = .session
                vc.session = session
                vc.isFirstLoadingSession = true
                
                vc.modalPresentationStyle = .fullScreen
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
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    guard self.totalBreaths > 0 else { return }
                    self.lblMindfulBreaths.text = "\(Int(self.mindfulBreathsCount*100/self.totalBreaths))% (\(self.mindfulBreathsCount) of \(self.totalBreaths))"
                }
//                self.currentSessionObject?.addBreath(timeStamp: self.sessionDuration * 60 - self.timeRemaining, isMindful: true, respRate: actualRR, targetRate: targetRR, eiRatio: 0, oneMinuteRR: 0)
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.totalBreaths > 0 else { return }
            self.lblMindfulBreaths.text = "\(Int(self.mindfulBreathsCount*100/self.totalBreaths))% (\(self.mindfulBreathsCount) of \(self.totalBreaths))"
        }
//        self.currentSessionObject?.addBreath(timeStamp: self.sessionDuration * 60 - self.timeRemaining, isMindful: false, respRate: actualRR, targetRate: targetRR, eiRatio: 0, oneMinuteRR: 0)
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.lblSlouches.text = String(self.slouchesCount);
            let elapsed = self.gameSetTime - self.trainingDuration
            guard elapsed > 0 else { return }
            self.lblUprightPosture.text = "\(Int(self.uprightPostureTime*100/elapsed))% (\(self.uprightPostureTime) of \(elapsed)s)"
        }
        
        prevPostureState = objLiveGraph.postureIsGood;
        if (trainingDuration == 0) {
            clearBuzzerTraining();
            
            PranaDeviceManager.shared.sendCommand("Buzz,2.5");
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.onComplete()
                self.btnStartStop.isEnabled = false
                self.btnStartStop.alpha = 0.5
                self.btnStartStop.setTitle("Session Completed!", for: .normal)
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

extension BuzzerTrainingViewController: RadioGroupButtonDelegate {
    func onSelectedIndex(index: Int, sender: RadioGroupButton) {
        if sender.tag == 1 {
            setBreathSensitivity(val: index)
        } else {
            setPostureSensitivity(val: index)
        }
    }
}

extension BuzzerTrainingViewController: LiveDelegate {
    
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        buzzerTrainingMainLoop()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.batteryView.progress = CGFloat(sensorData[6]) / 100.0
        }
    }
    
    func liveNew(postureFrame: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.displayPostureAnimation(postureFrame)
        }
    }
    
    func liveUprightHasBeenSet() {
        uprightHasBeenSetHandler()
    }
    
    func liveNew(sessionAvgRate: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.currentSessionObject?.avgRespRR = sessionAvgRate
        }
    }
}

extension BuzzerTrainingViewController: PranaDeviceManagerDelegate
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
