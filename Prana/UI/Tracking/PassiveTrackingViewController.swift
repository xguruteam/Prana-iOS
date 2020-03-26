//
//  PassiveTrackingViewController.swift
//  Prana
//
//  Created by Guru on 6/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Toaster

class PassiveTrackingViewController: SuperViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var batteryView: BatteryStateView!
    @IBOutlet weak var lblTimeElapsed: UILabel!
    @IBOutlet weak var liveGraph: LiveGraph!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var lblStatus4: UILabel!
    @IBOutlet weak var lblStatus5: UILabel!
    @IBOutlet weak var lblStatus6: UILabel!
    @IBOutlet weak var lblStatus9: UILabel!
    
    @IBOutlet weak var imgPosture: UIImageView!
    @IBOutlet weak var lblStatus7: UILabel!
    @IBOutlet weak var lblStatus8: UILabel!

    @IBOutlet weak var switchSlouching: UISwitch!
    @IBOutlet weak var ddBuzzIn: PranaDropDown!

    @IBOutlet weak var btnWearUpperChest: UIButton!
    
    @IBOutlet weak var btnWearLowerBack: UIButton!
    
    @IBOutlet weak var breathRadioGroup: RadioGroupButton!
    
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var postureRadioGroup: RadioGroupButton!
    @IBOutlet weak var lblGuide: UILabel!
    @IBOutlet weak var btnStartStop: UIButton!
    
    @IBOutlet weak var liveGraphHeight: NSLayoutConstraint!
    
    var currentRR: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus1.text = "\(self.currentRR)"
            }
        }
    }
    
    var oneMinuteRR: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus9.text = "\(self.oneMinuteRR)"
            }
        }
    }
    
    var averageRR: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus2.text = "\(self.averageRR)"
            }
        }
    }
    
    var breathCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus3.text = "\(self.breathCount)"
            }
        }
    }
    
    var realTimeEI: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus4.text = " \(self.realTimeEI)"
            }
        }
    }
    
    var sessionAvgEI: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus5.text = "\(self.sessionAvgEI)"
            }
        }
    }
    
    var lastMinuteEI: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus6.text = "\(self.lastMinuteEI)"
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
                self.lblStatus7.text = " \(Int(100.0 * Float(self.uprightPostureTime)/Float(self.trainingDuration)))% (\(self.uprightPostureTime) of \(self.trainingDuration)s)"
            }
        }
    }
    
    var slouchesCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblStatus8.text = "\(self.slouchesCount)"
            }
        }
    }
    
    var buzzTimeTrigger: Int = 5 {
        didSet {
            DispatchQueue.main.async {
                self.ddBuzzIn.title = self.buzzTimeTrigger == 0 ? "Immediate" : "Buzz in \(self.buzzTimeTrigger) Seconds"
            }
        }
    }
    
    
    var tempBuzzIn: Int = 0
    var sessionWearing: Int = 0
    
    var objLive: Live?
    
    var currentSessionObject: PassiveSession?
    
    var slouchStartSeconds: Int = 0
    
    var isLive = false

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        PranaDeviceManager.shared.addDelegate(self)
        // Do any additional setup after loading the view.
        initView()
        
        currentSlouchPostureTime = 0; //***May 31st ADDED
        lastMinuteEI = 0
        realTimeEI = 0
        sessionAvgEI = 0

        isPassiveTrackingActive = 0; // AUG 1st ADDED
        
        objLive = Live()
        objLive?.appMode = 1
        objLive?.addDelegate(self)
        liveGraph.objLive = objLive
        
        objLive?.startMode() //Need this here because user needs to be able set posture before timer starts!
        
        objLive?.breathTopExceededThreshold = 0 //AUG 1st NEW
        objLive?.lightBreathsThreshold = 0 //AUG 1st NEW
        
        switch dataController.sensitivities.ptps {
        case 0:
            setPostureSensitivity(val: 1)
        case 1:
            setPostureSensitivity(val: 2)
        default:
            setPostureSensitivity(val: 3)
        }

        setBreathSensitivity(val: 1)
        useBuzzerForPosture = 1
        buzzTimeTrigger = 5; // May 31st ADDED THIS LINE
        
        currentRR = 0
        averageRR = 0
        breathCount = 0
        oneMinuteRR = 0
        
        slouchesCount = 0
        uprightPostureTime = 0
        hasUprightBeenSet = 0
        totalBreaths = 0
        
        adjustContraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        btnUpright.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        btnUpright.isHighlighted = false
        btnStartStop.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
    }
    
    func initView() {
        btnStartStop.setTitle("START TRACKING", for: .normal)
        setWearPosition(val: 0)
        
        lblGuide.isHidden = false
        btnStartStop.isHidden = true
        
        ddBuzzIn.clickListener = { [weak self] in
            self?.openBuzzInPicker()
        }
        
        breathRadioGroup.delegate = self
        postureRadioGroup.delegate = self
    }
    
    func adjustContraints() {
        if UIScreen.main.nativeBounds.height >= 1920 { // above 8 plus
            liveGraphHeight.constant = 150
        }
    }

    @IBAction func onBack(_ sender: Any) {
        objLive?.removeDelegate(self)
        objLive?.stopMode(reset: dataController.isAutoReset)
        liveGraph.objLive = nil
        objLive = nil
        PranaDeviceManager.shared.removeDelegate(self)
        
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
            .list("E/I Ratio is the ratio of your exhalation time to your inhalation time. If on average you are exhaling faster than your inhalations (which means this ratio is less than 1.0), this can also be an indicator of stress, depending how much less than 1.0 it is."),
        ]
        
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
    
    @IBAction func onUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
    }
    
    @IBAction func onStartStop(_ sender: Any) {
        if isLive {
            closeTracking()
        }
        else {
            startLiving()
        }
    }
    
    func closeTracking() {
        stopLiving()
        
        currentSessionObject?.floorSessionDuration()
        
        if let session = currentSessionObject, session.duration >= 60 {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dataController = appDelegate.dataController {
                dataController.addRecord(passive: session)
            }
            let vc = getViewController(storyboard: "History", identifier: "SessionDetailViewController") as! SessionDetailViewController
            vc.type = .passive
            vc.passive = session
            vc.isFirstLoadingSession = true
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
        currentSessionObject = nil
    }
    
    @IBAction func onEnableSlouchBuzzChange(_ sender: Any) {
        useBuzzerForPosture = switchSlouching.isOn ? 1 : 0
    }
    
    @IBAction func onWearingChange(_ sender: UIButton) {
        setWearPosition(val:sender.tag)
        displayPostureAnimation(1)
    }
    
    @objc func appMovedToBackground() {
        print("Passive Tracking: App moved to background!")
        if !isLive {
            closeTracking()
            
            if PranaDeviceManager.shared.isConnected {
                PranaDeviceManager.shared.disconnect()
            }
        }
    }
    
    func setWearPosition(val: Int) {
        if val == 0 {
            btnWearLowerBack.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)
            btnWearLowerBack.setTitleColor(UIColor.white, for: .normal)
            btnWearLowerBack.setImage(#imageLiteral(resourceName: "ic_lower_back_white"), for: .normal)
            
            btnWearUpperChest.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            btnWearUpperChest.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4392156863, blue: 0.5254901961, alpha: 1), for: .normal)
            btnWearUpperChest.setImage(#imageLiteral(resourceName: "ic_upper_chest_grey"), for: .normal)
            
            sessionWearing = 0
        } else {
            btnWearLowerBack.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            btnWearLowerBack.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4392156863, blue: 0.5254901961, alpha: 1), for: .normal)
            btnWearLowerBack.setImage(#imageLiteral(resourceName: "ic_lower_back_grey"), for: .normal)
            
            btnWearUpperChest.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)
            btnWearUpperChest.setTitleColor(UIColor.white, for: .normal)
            btnWearUpperChest.setImage(#imageLiteral(resourceName: "ic_upper_chest_white"), for: .normal)
            
            sessionWearing = 1
        }
        
        displayPostureAnimation(1)
    }
    
    func uprightHasBeenSetHandler() {
        if hasUprightBeenSet == 0 {
            hasUprightBeenSet = 1
            DispatchQueue.main.async {
                self.btnStartStop.isHidden = false
                self.lblGuide.isHidden = true
//                self.btnUpright.setTitle("SET UPRIGHT ✅", for: .normal)
            }
        }
    }
    
    func setBreathSensitivity(val: Int) {
        breathRadioGroup.selectedIndex = val
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        postureRadioGroup.selectedIndex = val
        dataController.sensitivities.ptps = val - 1
        dataController.saveSettings()
        
        objLive?.setPostureResponsiveness(val: val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        let frame = whichFrame
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

        currentSessionObject = PassiveSession(startedAt: Date(), wearing: sessionWearing)
        
        btnBack.isHidden = true
        btnHelp.isHidden = true
        
        objLive?.isBuzzing = 0; //May 19th Changed
        buzzCount = 0;
        isPassiveTrackingActive = 1; // May 19th, ADDED THIS LINE
        
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
        self.btnStartStop.isHidden = false
        self.lblGuide.isHidden = true
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
        liveGraph.objLive = nil
        objLive = nil
    }
    
    func makeSessionObject() {
        let duration = trainingDuration
        if duration > 0, breathCount > 0 {
            currentSessionObject?.duration = duration
        }
    }
    
    var buzzCount:Int = 0;
    var hasUprightBeenSet:Int = 0;
    var prevPostureState:Int = 0;
    var enterFrameCount:Int = 0;
    var totalBreaths:Int = 0;
    var useBuzzerForPosture:Int = 1;
    var isPassiveTrackingActive:Int = 0;  // May 19th, ADDED THIS LINE
    var currentSlouchPostureTime:Int = 0; // May 31st ADDED THIS LINE

    func passiveTrackingMainLoop() {
        guard isPassiveTrackingActive == 1 else { return }
        
        currentRR = Float(objLive!.respRate)
        breathCount = objLive!.breathCount
        averageRR = Float(objLive!.avgRespRate)
        
        timerHandler();
        
        if (buzzCount > 0) {
            buzzCount-=1;
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
            currentSessionObject?.avgEIRate = objLive!.EIAvgSessionRatio
        }

        trainingDuration+=1;
        makeSessionObject()
        
        if (objLive?.postureIsGood == 1) {
            if (prevPostureState == 0) {
                if slouchStartSeconds > 0, currentSlouchPostureTime > 0 {
                    currentSessionObject?.addSlouch(timeStamp: slouchStartSeconds, duration: currentSlouchPostureTime)
                    // slouch end
                }
            }
            
            uprightPostureTime+=1;
            currentSlouchPostureTime = 0; // May 31st ADDED THIS
        }
        else {  // May 31st ADDED THIS
            currentSlouchPostureTime+=1;  // May 31st ADDED THIS
            uprightPostureTime = uprightPostureTime + 0
        }  // May 31st ADDED THIS
        
        
        if (prevPostureState == 1) {
            if (objLive?.postureIsGood == 0) {
                slouchesCount+=1;
                slouchStartSeconds = trainingDuration
            }
        }
        
        prevPostureState = objLive!.postureIsGood;
    }
    

}

extension PassiveTrackingViewController: RadioGroupButtonDelegate {
    func onSelectedIndex(index: Int, sender: RadioGroupButton) {
        if sender.tag == 1 {
            setBreathSensitivity(val: index)
        } else {
            setPostureSensitivity(val: index)
        }
    }
}

extension PassiveTrackingViewController: LiveDelegate {
    
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
    
    func liveNew(sessionAvgRate: Double) {
        currentSessionObject?.avgRespRR = sessionAvgRate
    }
}

extension PassiveTrackingViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.closeTracking()
            self.batteryView.progress = 0
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
}
