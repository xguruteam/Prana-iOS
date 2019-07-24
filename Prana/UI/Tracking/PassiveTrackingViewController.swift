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
    @IBOutlet weak var liveGraph: LiveGraph!
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
            lblStatus1.text = "Real-time: \(currentRR)"
        }
    }
    
    var oneMinuteRR: Float = 0 {
        didSet {
            lblStatus9.text = "1-minute: \(oneMinuteRR)"
        }
    }
    
    var avgRR: Float = 0 {
        didSet {
            lblStatus2.text = "Session avg: \(avgRR)"
        }
    }
    
    var breathCount: Int = 0 {
        didSet {
            lblStatus3.text = "Breath Count: \(breathCount)"
        }
    }
    
    var realTimeEI: Float = 0 {
        didSet {
            lblStatus4.text = "Real-time: \(realTimeEI)"
        }
    }
    
    var avgEI: Float = 0 {
        didSet {
            lblStatus5.text = "Session avg: \(avgEI)"
        }
    }
    
    var lastEI: Float = 0 {
        didSet {
            lblStatus6.text = "1-minute: \(lastEI)"
        }
    }
    
    var timeElapsed: Int = 0 {
        didSet {
            lblTimeElapsed.text = "\(styledTime(v: timeElapsed))"
        }
    }
    
    var uprightSeconds: Int = 0 {
        didSet {
            guard timeElapsed > 0 else { return }
            lblStatus7.text = "Upright Posture: \(Int(100.0 * Float(uprightSeconds)/Float(timeElapsed)))% (\(uprightSeconds) of \(timeElapsed) s)"
        }
    }
    
    var slouches: Int = 0 {
        didSet {
            lblStatus8.text = "Slouches: \(slouches)"
        }
    }
    
    var buzzIn: Int = 5 {
        didSet {
            ddBuzzIn.title = buzzIn == 0 ? "Immediate" : "\(buzzIn) Seconds"
            objPassive?.buzzTimeTrigger = buzzIn
        }
    }
    var tempBuzzIn: Int = 0
    var sessionWearing: Int = 0
    
    var objLive: Live?
    var objPassive: Passive?
    
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
        
        currentRR = 0
        avgRR = 0
        breathCount = 0
        realTimeEI = 0
        avgEI = 0
        lastEI = 0
        oneMinuteRR = 0
        buzzIn = 5
        
        objLive = Live()
        objLive?.appMode = 1
        objLive?.addDelegate(self)
        liveGraph.objLive = objLive
        
        objPassive = Passive(live: objLive!)
        objPassive?.delegate = self
        
        setBreathSensitivity(val: 1)
        setPostureSensitivity(val: 2)

        displayPostureAnimation(1)
        
        lblGuide.isHidden = false
        btnStartStop.isHidden = true
        
        ddBuzzIn.clickListener = { [weak self] in
            self?.openBuzzInPicker()
        }
        
        PranaDeviceManager.shared.startGettingLiveData()

    }
    
    func styledTime(v: Int) -> String {
        let m = Int(v / 60)
        let s = v - m * 60
        
        return String(format: "%d:%02d", m, s)
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
    }
    

    @IBAction func onBack(_ sender: Any) {
        objLive?.removeDelegate(self)
        objLive = nil
        PranaDeviceManager.shared.stopGettingLiveData()
        
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
        objPassive?.useBuzzerForPosture = switchSlouching.isOn ? 1 : 0
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
        if objPassive?.hasUprightBeenSet == 0 {
            objPassive?.hasUprightBeenSet = 1
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
        tempBuzzIn = buzzIn
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
            self.buzzIn = self.tempBuzzIn
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
        
        objPassive?.useBuzzerForPosture = switchSlouching.isOn ? 1 : 0
        objPassive?.buzzTimeTrigger = buzzIn
        
        objPassive?.start()
        btnBack.isHidden = true
        btnHelp.isHidden = true
    }
    
    func stopLiving() {
        isLive = false
        btnStartStop.setTitle("TRACKING ENDED", for: .normal)
        btnStartStop.isEnabled = false
        objPassive?.stop()
        objPassive = nil
        PranaDeviceManager.shared.stopGettingLiveData()
        btnBack.isHidden = false
        btnHelp.isHidden = false
        
    }
    
    func makeSessionObject() {
        var duration = timeElapsed
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

}

extension PassiveTrackingViewController: LiveDelegate {
    func liveProcess(sensorData: [Double]) {
        DispatchQueue.main.async {
            self.batteryView.progress = CGFloat(sensorData[6]) / 100.0
        }
    }
    
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
