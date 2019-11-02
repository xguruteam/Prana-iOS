//
//  PassiveTrackingViewController.swift
//  Prana
//
//  Created by Guru on 6/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PassiveTrackingViewController: SuperViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var batteryView: BatteryStateView!
    @IBOutlet weak var lblTimeElapsed: UILabel!
    @IBOutlet weak var liveGraph: LiveGraph2!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var lblStatus4: UILabel!
    @IBOutlet weak var lblStatus5: UILabel!
    @IBOutlet weak var lblStatus6: UILabel!
    @IBOutlet weak var lblStatus9: UILabel!
    
    @IBOutlet weak var btnBreathSense1: UIButton!
    @IBOutlet weak var btnBreathSense2: UIButton!
    @IBOutlet weak var btnBreathSense3: UIButton!
    
    @IBOutlet weak var imgPosture: UIImageView!
    @IBOutlet weak var lblStatus7: UILabel!
    @IBOutlet weak var lblStatus8: UILabel!

    @IBOutlet weak var switchSlouching: UISwitch!
    @IBOutlet weak var ddBuzzIn: PranaDropDown!
    @IBOutlet weak var btWearing1: PranaButton!
    @IBOutlet weak var btWearing2: PranaButton!
    
    @IBOutlet weak var btnPostureSense1: UIButton!
    @IBOutlet weak var btnPostureSense2: UIButton!
    @IBOutlet weak var btnPostureSense3: UIButton!
    
    @IBOutlet weak var breathSenseGroup: UIView!
    @IBOutlet weak var postureSenseGroup: UIView!
    
    @IBOutlet weak var lblGuide: UILabel!
    @IBOutlet weak var btnStartStop: UIButton!
    
    var currentRR: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus1.text = "Real-time: \(self.currentRR)"
            }
        }
    }
    
    var oneMinuteRR: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus9.text = "1-minute: \(self.oneMinuteRR)"
            }
        }
    }
    
    var averageRR: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus2.text = "Session avg: \(self.averageRR)"
            }
        }
    }
    
    var breathCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus3.text = "Breath Count: \(self.breathCount)"
            }
        }
    }
    
    var realTimeEI: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus4.text = "Real-time: \(self.realTimeEI)"
            }
        }
    }
    
    var sessionAvgEI: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus5.text = "Session avg: \(self.sessionAvgEI)"
            }
        }
    }
    
    var lastMinuteEI: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus6.text = "1-minute: \(self.lastMinuteEI)"
            }
        }
    }
    
    var trainingDuration: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblTimeElapsed.text = "\(styledTime(v: self.trainingDuration))"
            }
        }
    }
    
    var uprightPostureTime: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                guard self.trainingDuration > 0 else { return }
                self.lblStatus7.text = "Upright Posture: \(Int(100.0 * Float(self.uprightPostureTime)/Float(self.trainingDuration)))% (\(self.uprightPostureTime) of \(self.trainingDuration) s)"
            }
        }
    }
    
    var slouchesCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus8.text = "Slouches: \(self.slouchesCount)"
            }
        }
    }
    
    var buzzTimeTrigger: Int = 5 {
        didSet {
            DispatchQueue.main.async {
                self.ddBuzzIn.title = self.buzzTimeTrigger == 0 ? "Immediate" : "\(self.buzzTimeTrigger) Seconds"
            }
        }
    }
    
    
    var tempBuzzIn: Int = 0
    var sessionWearing: Int = 0
    
    var objLive: Live2?
    
    var currentSessionObject: PassiveSession?
    
    var slouchStartSeconds: Int = 0
    
    var isLive = false

    deinit {
        print("PassiveTrackingViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Do any additional setup after loading the view.
        initView()
        
        currentSlouchPostureTime = 0; //***May 31st ADDED
        lastMinuteEI = 0
        realTimeEI = 0
        sessionAvgEI = 0

        isPassiveTrackingActive = 0; // AUG 1st ADDED
        
        objLive = Live2()
        objLive?.appMode = 1
        objLive?.addDelegate(self)
        liveGraph.objLive = objLive
        
        objLive?.startMode(); //Need this here because user needs to be able set posture before timer starts!
        
        objLive?.breathTopExceededThreshold = 0; //AUG 1st NEW
        objLive?.lightBreathsThreshold = 0; //AUG 1st NEW
        
        switch dataController.sensitivities.ptps {
        case 0:
            setPostureSensitivity(val: 1)
        case 1:
            setPostureSensitivity(val: 2)
        default:
            setPostureSensitivity(val: 3)
        }

        setBreathSensitivity(val: 1)
        
        useBuzzerForPosture = 1;
        
        buzzTimeTrigger = 5; // May 31st ADDED THIS LINE
        
        currentRR = 0
        averageRR = 0
        breathCount = 0
        oneMinuteRR = 0
        
        slouchesCount = 0;
        uprightPostureTime = 0;
        hasUprightBeenSet = 0;
        totalBreaths = 0;    
    }
    
    func initView() {
        
        let border1 = CALayer()
        border1.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border1.frame = CGRect(x: 0.0, y: breathSenseGroup.frame.height + 4.0, width: breathSenseGroup.frame.width, height: 1.0)
        
        breathSenseGroup.layer.addSublayer(border1)
        
        let border2 = CALayer()
        border2.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border2.frame = CGRect(x: 0.0, y: postureSenseGroup.frame.height + 4.0, width: postureSenseGroup.frame.width, height: 1.0)
        
        postureSenseGroup.layer.addSublayer(border2)
        
//        switchSlouching.tintColor = UIColor(hexString: "#2bb7b8")
        switchSlouching.onTintColor = UIColor(hexString: "#2bb7b8")
        
        btnStartStop.setTitle("START TRACKING", for: .normal)
        
        displayPostureAnimation(1)
        
        lblGuide.isHidden = false
        btnStartStop.isHidden = true
        
        ddBuzzIn.clickListener = { [weak self] in
            self?.openBuzzInPicker()
        }
    }
    

    @IBAction func onBack(_ sender: Any) {
        objLive?.removeDelegate(self)
        objLive?.stopMode(reset: dataController.isAutoReset)
        objLive = nil
        
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        let text: [AttributedTextBlock] = [
            .list("Tracking allows you to track both your breathing and posture in the background, not requiring your attention. Tracking is recommended only while sitting or standing, not walking or running. You can track for as long as you wish."),
            .list("Tracking is useful to learn how your breathing and posture are working unconsciously (what your average respiration rate is and how often you are slouching). A higher non-active respiration rate can be linked to more stressed situations."),
            .list("You can opt to get buzzes when slouching in this mode. You can set the buzz times to be less frequent/strict than in training mode."),
            .list("If you are discovering stressed breathing or poor posture during tracking, our suggestion in both cases is just to hop into training mode and do a training session, and/or adjust your daily training minute goals."),
        ]
        
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
    
    @IBAction func onBreathResponsivenessChange(_ sender: UIButton) {
        setBreathSensitivity(val: sender.tag)
    }
    
    @IBAction func onPostureSenseChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    @IBAction func onUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
    }
    
    @IBAction func onStartStop(_ sender: Any) {
        if isLive {
            stopLiving()
            
            currentSessionObject?.floorSessionDuration()
            
            if let session = currentSessionObject, session.duration > 0 {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                    dataController.addRecord(passive: session)
                }
                let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
                vc.type = .passive
                vc.passive = session
                self.present(vc, animated: true, completion: nil)
            }
            
            currentSessionObject = nil
            

        }
        else {
            startLiving()
        }
    }
    
    @IBAction func onEnableSlouchBuzzChange(_ sender: Any) {
        useBuzzerForPosture = switchSlouching.isOn ? 1 : 0
    }
    
    @IBAction func onWearingChange(_ sender: UIButton) {
        if sender.tag == 0 {
            btWearing1.isClicked = true
            btWearing2.isClicked = false
            sessionWearing = 0
        }
        else {
            btWearing1.isClicked = false
            btWearing2.isClicked = true
            
            sessionWearing = 1
        }
        
        displayPostureAnimation(1)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        if !isLive {
            onBack(btnStartStop)
            
            if PranaDeviceManager.shared.isConnected {
                PranaDeviceManager.shared.disconnect()
            }
        }
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
        btnBreathSense1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSense2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSense3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnBreathSense1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnBreathSense2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnBreathSense3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        btnPostureSense1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSense2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSense3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnPostureSense1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnPostureSense2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnPostureSense3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        dataController.sensitivities.ptps = val - 1
        dataController.saveSettings()
        
        objLive?.setPostureResponsiveness(val: val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        var frame = whichFrame
        if sessionWearing == 0 {
            imgPosture.image = UIImage(named: "sit (\(frame))")
        }
        else {
            imgPosture.image = UIImage(named: "stand (\(frame))")
        }
    }
    
    func openBuzzInPicker() {
        tempBuzzIn = buzzTimeTrigger
        let alert = UIAlertController(style: .actionSheet, title: "Buzz In", message: nil)
        
        let frameSizes: [Int] = [0, 3, 5, 10, 15, 20, 30]
        let pickerViewValues: [[String]] = [frameSizes.map { $0 == 0 ? "Immediate" : "\($0) Seconds" }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: tempBuzzIn) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            DispatchQueue.main.async {
                self.tempBuzzIn = frameSizes[index.row]
            }
        }
        alert.addAction(title: "Done", style: .default) { (_) in
            self.buzzTimeTrigger = self.tempBuzzIn
        }
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.show(style: .prominent)
    }
    
    func startLiving() {
        isLive = true
        btnStartStop.setTitle("END TRACKING", for: .normal)
        
        
//        self.switchSlouching.isEnabled = false
//        self.ddBuzzIn.isEnabled = false
        self.btWearing1.isEnabled = false
        self.btWearing2.isEnabled = false

        currentSessionObject = PassiveSession(startedAt: Date(), wearing: sessionWearing)
        
        btnBack.isHidden = true
        btnHelp.isHidden = true
        
        objLive?.isBuzzing = 0; //May 19th Changed
        buzzCount = 0;
        //addEventListener(Event.ENTER_FRAME, enterFrameHandler);  // May 19th, REMOVED THIS LINE
        isPassiveTrackingActive = 1; // May 19th, ADDED THIS LINE
        
        //DC.objLiveGraph.whenBreathsEnd = [];   //AUG 1st REMOVED
        //DC.objLiveGraph.whenBreathsEnd[0] = 0; //AUG 1st REMOVED
        objLive?.breathCount = 0;
        objLive?.timeElapsed = 0;
        objLive?.respRate = 0;
        objLive?.avgRespRate = 0;
        
        objLive?.exhaleCorrectionFactor = 0; //AUG 1st NEW
        objLive?.EIAvgSessionRatio = 0; //AUG 1st NEW
        objLive?.EIRatio = [];  //AUG 1st NEW
        objLive?.inhaleStartTime = 0; //AUG 1st NEW
        objLive?.inhaleEndTime = 0; //AUG 1st NEW
        objLive?.exhaleEndTime = 0; //AUG 1st NEW
        objLive?.EIRatioCount = 0; //AUG 1st NEW
        objLive?.EI1Minute = 0;  //AUG 1st NEW
        objLive?.whenBreathsStart = []; //AUG 1st NEW
        objLive?.enterFrameCount = 0; //AUG 1st NEW
        objLive?.EIAvgSessionSummation = 0; //AUG 1st NEW
        
        objLive?.breathTopExceededThreshold = 1; //AUG 1st NEW
        objLive?.lightBreathsThreshold = 1; //AUG 1st NEW
        objLive?.minBreathRange = objLive!.fullBreathGraphHeight/16; //AUG 1st CHANGE
        objLive?.minBreathRangeForStuck = (objLive!.fullBreathGraphHeight/16); //AUG 1st NEW
    }
    
    func stopLiving() {
        isLive = false
        btnStartStop.setTitle("TRACKING ENDED", for: .normal)
        btnStartStop.isEnabled = false
        
        btnBack.isHidden = false
        btnHelp.isHidden = false
        
        //removeEventListener(Event.ENTER_FRAME, enterFrameHandler);  // May 19th, REMOVED THIS LINE
        isPassiveTrackingActive = 0; // May 19th, ADDED THIS LINE
        
        objLive?.isBuzzing = 0; //May 19th Changed
        buzzCount = 0;
        prevPostureState = 0;
        objLive?.removeDelegate(self)
        objLive?.stopMode(reset: dataController.isAutoReset)
        objLive = nil
    }
    
    func makeSessionObject() {
        var duration = trainingDuration
        if duration > 0, breathCount > 0 {
            currentSessionObject?.duration = duration
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
    
    // MARK: Original Action Script
    //var isBuzzing:int = 0; May 19th  REMOVE (we are now using isBuzzing in BuzzerTraining class as a global variable)
    var buzzCount:Int = 0;
    var hasUprightBeenSet:Int = 0;
//    var trainingDuration:Int = 0;
//    var slouchesCount:Int = 0;
//    var uprightPostureTime:Int = 0;
    var prevPostureState:Int = 0;
    var enterFrameCount:Int = 0;
    var totalBreaths:Int = 0;
    var useBuzzerForPosture:Int = 1;
    var isPassiveTrackingActive:Int = 0;  // May 19th, ADDED THIS LINE
    var currentSlouchPostureTime:Int = 0; // May 31st ADDED THIS LINE
//    var buzzTimeTrigger:Int = 0;  // May 31st ADDED THIS LINE
    //var secondsElapsed:int = 0; //JULY 13th:CHANGE1b  REMOVE THIS LINE
    
    func passiveTrackingMainLoop() {
        guard isPassiveTrackingActive == 1 else { return }
        
        currentRR = Float(objLive!.respRate)
        
        //if (DC.objLiveGraph.timeElapsed >= 60) { //AUG 1st REMOVED
        //passiveTrackingUI.oneMinuteRR.text = String(DC.objLiveGraph.calculateOneMinuteRespRate()); //AUG 1st REMOVED
        //} //AUG 1st REMOVED
        
        breathCount = objLive!.breathCount
        averageRR = Float(objLive!.avgRespRate)
        
        timerHandler();
        
        if (buzzCount > 0) {
            
            buzzCount-=1;
            
            //if (buzzCount == 0) { //May 19th REMOVED
            //DC.objBuzzerTraining.isBuzzing = 0; May 19th REMOVED
            //DC.objLiveGraph.dampingLevel = 0;  May 19th REMOVED
            //DC.objLiveGraph.postureAttenuatorLevel = 0;  May 19th REMOVED
            //}
            
        }
        
        
        if (buzzCount == 0 && objLive?.postureIsGood == 0 && useBuzzerForPosture == 1 && objLive?.isBuzzing == 0 && currentSlouchPostureTime >= buzzTimeTrigger)  { //May 31st Changed
            
            PranaDeviceManager.shared.sendCommand("Buzz,1"); //May 19th Changed
            objLive?.isBuzzing = 1; //May 19th Changed
            buzzCount = 150; //May 19th Change
        }
        
        if (buzzCount == 120) { //May 19th ADDED LINE
            
            PranaDeviceManager.shared.sendCommand("Buzz,1"); //May 19th ADDED LINE
            
        } //May 19th ADDED LINE
        
        if (buzzCount == 90) { //May 19th ADDED LINE
            objLive?.isBuzzing = 0; //May 19th ADDED LINE
            objLive?.dampingLevel = 0; //May 19th ADDED LINE
            objLive?.postureAttenuatorLevel = 0; //May 19th ADDED LINE
        } //May 19th ADDED LINE
    }
    
    func timerHandler() {
        enterFrameCount+=1;
        
        if (enterFrameCount < 20) {  //May 19th, changed from 60 to 20
            return;
        }
        
        enterFrameCount = 0;
        
        if (objLive!.timeElapsed >= 60) { //AUG 1st NEW
            oneMinuteRR = Float(objLive!.calculateOneMinuteRespRate())
            
            objLive?.calculateOneMinuteEI(); //AUG 1st NEW
            lastMinuteEI = Float(objLive!.EI1Minute); //Aug 1st NEW
        } //AUG 1st NEW
        
        if (objLive?.EIRatio.count > 0) {  //May 31st ADDED
            realTimeEI = Float(objLive!.EIRatio[objLive!.EIRatio.count-1][0]);   //May 31st ADDED
            sessionAvgEI = Float(objLive!.EIAvgSessionRatio);   //AUG 1st CHANGED
        }
        
        //secondsElapsed++;  //JULY 13th:CHANGE1b  REMOVE THIS LINE
        
        //if (DC.objLiveGraph.timeElapsed >= 60) {  //AUG 1st REMOVED
        //secondsElapsed = 0; //JULY 13th:CHANGE1b  REMOVE THIS LINE
        //passiveTrackingUI.lastMinuteEI.text = String(DC.objLiveGraph.EI1Minute); //AUG 1st REMOVED
        //} //AUG 1st REMOVED
        
        
        trainingDuration+=1;
        makeSessionObject()
        
        if (objLive?.postureIsGood == 1) {
            uprightPostureTime+=1;
            currentSlouchPostureTime = 0; // May 31st ADDED THIS
        }
        else {  // May 31st ADDED THIS
            currentSlouchPostureTime+=1;  // May 31st ADDED THIS
        }  // May 31st ADDED THIS
        
        
        if (prevPostureState == 1) {
            if (objLive?.postureIsGood == 0) {
                slouchesCount+=1;
                slouchStartSeconds = trainingDuration - currentSlouchPostureTime
                if slouchStartSeconds > 0, currentSlouchPostureTime > 0 {
                    currentSessionObject?.addSlouch(timeStamp: slouchStartSeconds, duration: currentSlouchPostureTime)
                    // slouch end
                }
            }
        }
        
//        uprightSeconds = uprightPostureTime
//        slouches = slouchesCount;
        
        prevPostureState = objLive!.postureIsGood;
    }
    

}

extension PassiveTrackingViewController: Live2Delegate {
    
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        passiveTrackingMainLoop()
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
    
    func liveNew(breathCount: Int) {
        currentSessionObject?.addBreath(timeStamp: trainingDuration, isMindful: false, respRate: Double(currentRR), eiRatio: Double(lastMinuteEI), oneMinuteRR: Double(oneMinuteRR))
    }
}

/*
extension PassiveTrackingViewController: PassiveDelegate {
    func passiveDidRespRate(currentRR: Double, avgRR: Double, breathCount: Int) {
        if self.breathCount < breathCount {
            // new breath
            currentSessionObject?.addBreath(timeStamp: timeElapsed, isMindful: false, respRate: currentRR, eiRatio: Double(lastEI), oneMinuteRR: Double(oneMinuteRR))
        }
        DispatchQueue.main.async {
            self.breathCount = breathCount
            self.currentRR = Float(currentRR)
            self.avgRR = Float(avgRR)
        }

    }
    
    func passiveDidEI(realtimeEI: Double, avgEI: Double) {
        DispatchQueue.main.async {
            self.realTimeEI = Float(realtimeEI)
            self.avgEI = Float(avgEI)
        }

    }
    
    func passiveDidCalculateOneMinuteEI(lastEI: Double) {
        DispatchQueue.main.async {
            self.lastEI = Float(lastEI)
        }

    }
    
    func passiveUprightTime(seconds: Int) {
        if uprightSeconds == seconds {
            // new slouch start
            slouchStartSeconds = timeElapsed
        }
        else {
            if uprightSeconds < seconds {
                let slouchDuration = timeElapsed - slouchStartSeconds
                if slouchStartSeconds > 0, slouchDuration > 0 {
                    currentSessionObject?.addSlouch(timeStamp: slouchStartSeconds, duration: slouchDuration)
                    // slouch end
                }
            }
            slouchStartSeconds = 0
        }
        DispatchQueue.main.async {
            self.uprightSeconds = seconds
        }
    }
    
    func passiveSlouches(slouches: Int) {
        DispatchQueue.main.async {
            self.slouches = slouches
        }
    }
    
    func passiveTimeElapsed(elapsed: Int) {
        DispatchQueue.main.async {
            self.timeElapsed = elapsed
            self.makeSessionObject()
        }
    }
    
    func passiveDidCalculateOneMinuteRespRate(oneMinuteRR: Int) {
        DispatchQueue.main.async {
            self.oneMinuteRR = Float(oneMinuteRR)
        }
    }
}
*/
