//
//  LiveGraphViewController.swift
//  Prana
//
//  Created by Luccas on 4/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth
import Macaw

class LiveGraphViewController: SuperViewController {
    
//    @IBOutlet weak var btStartStop: UIButton!
    @IBOutlet weak var breathingGraphView: LiveGraph!
    
    //    @IBOutlet weak var postureIndicatorView: PostureIndicator!
    @IBOutlet weak var breathSensitivityGroup: UIView!
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio1: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle1: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio2: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle2: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio3: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle3: UIButton!
    
    @IBOutlet weak var lblRespirationRate: UILabel!
    @IBOutlet weak var lblBreathCount: UILabel!
    @IBOutlet weak var lblOneMinutes: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    
    @IBOutlet weak var postureSensitivityGroup: UIView!
    @IBOutlet weak var btnPostureSensitivityRadio1: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle1: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio2: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle2: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio3: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle3: UIButton!
    
    @IBOutlet weak var btnWearLowerBack: UIButton!
    @IBOutlet weak var btnWearUpperChest: UIButton!
    
    @IBOutlet weak var batteryView: BatteryStateView!
    
    var isLive = false
    var objLive: Live?
    var isLowerBack = true
    var isFinish = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        initView()
        
        objLive = Live()
        objLive?.appMode = 1
        objLive?.addDelegate(self)
        breathingGraphView.objLive = objLive
        
        switch dataController.sensitivities.lgbr {
        case 0:
            setBreathSensitivity(val: 1)
        case 1:
            setBreathSensitivity(val: 2)
        default:
            setBreathSensitivity(val: 3)
        }
        
        switch dataController.sensitivities.lgps {
        case 0:
            setPostureSensitivity(val: 1)
        case 1:
            setPostureSensitivity(val: 2)
        default:
            setPostureSensitivity(val: 3)
        }
        
        displayPostureAnimation(1)
        displayBreathCount(val: 0)
        displayRespirationRate(val: 0)
        lblOneMinutes.text = "1-minute: 0"
        
        setWearPosition(val: 0)
        
        startLive()
        
        batteryView.isGray = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFinish { return }
        stopLive()
    }
    
    func initView() {
        btnWearLowerBack.titleLabel?.textAlignment = .center
        btnWearUpperChest.titleLabel?.textAlignment = .center
        
        let border1 = CALayer()
        border1.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border1.frame = CGRect(x: 0.0, y: breathSensitivityGroup.frame.height + 4.0, width: breathSensitivityGroup.frame.width, height: 1.0)
        
        breathSensitivityGroup.layer.addSublayer(border1)
        
        let border2 = CALayer()
        border2.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border2.frame = CGRect(x: 0.0, y: postureSensitivityGroup.frame.height + 4.0, width: postureSensitivityGroup.frame.width, height: 1.0)
        
        postureSensitivityGroup.layer.addSublayer(border2)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    @IBAction func onBack(_ sender: Any) {
        isFinish = true
        stopLive()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
    }
    
    @IBAction func onBreathSensitivityChange(_ sender: UIButton) {
        setBreathSensitivity(val: sender.tag)
    }
    
    @IBAction func onPostureSensitivityChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    @IBAction func onWearPositionChange(_ sender: UIButton) {
        setWearPosition(val: sender.tag)
    }
    
    func startLive() {
        if !PranaDeviceManager.shared.isConnected {
            let alert = UIAlertController(title: "Prana", message: "No Prana Device is connected. Please Search and connect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        isLive = true
        
        objLive?.startMode()
    }
    
    func stopLive() {
        isLive = false
        
        breathingGraphView.objLive = nil
        objLive?.removeDelegate(self)
        
        objLive?.stopMode(reset: dataController.isAutoReset)
        
        objLive = nil
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
        dataController.sensitivities.lgbr = val - 1
        dataController.saveSettings()
        
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
        dataController.sensitivities.lgps = val - 1
        dataController.saveSettings()

        objLive?.setPostureResponsiveness(val: val)
    }
    
    func setWearPosition(val: Int) {
        if val == 0 {
            btnWearLowerBack.backgroundColor
             = UIColor(red: 0.43, green: 0.75, blue: 0.23, alpha: 1)
            btnWearLowerBack.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            
            btnWearUpperChest.backgroundColor
                = UIColor(red: 0.965, green: 0.97, blue: 0.98, alpha: 1)
            btnWearUpperChest.setTitleColor(UIColor(red: 0.47, green: 0.52, blue: 0.62, alpha: 1.0), for: .normal)
            isLowerBack = true
        } else {
            btnWearLowerBack.backgroundColor
                = UIColor(red: 0.965, green: 0.97, blue: 0.98, alpha: 1)
            btnWearLowerBack.setTitleColor(UIColor(red: 0.47, green: 0.52, blue: 0.62, alpha: 1.0), for: .normal)
            
            btnWearUpperChest.backgroundColor
                = UIColor(red: 0.43, green: 0.75, blue: 0.23, alpha: 1)
            btnWearUpperChest.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            isLowerBack = false
        }
        displayPostureAnimation(1)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        var frame = whichFrame
        
        if isLowerBack {
            imgPostureAnimation.image = UIImage(named: "sit (\(frame))")
        }
        else {
            imgPostureAnimation.image = UIImage(named: "stand (\(frame))")
        }
    }
    
    func displayRespirationRate(val: Double) {
        lblRespirationRate.text = String(val)
    }
    
    func displayBreathCount(val: Int) {
        lblBreathCount.text = String(val)
    }

}

extension LiveGraphViewController: LiveDelegate {
    
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        DispatchQueue.main.async {
            self.batteryView.progress = CGFloat(sensorData[6]) / 100.0
            
            let v = Int(timeElapsed)
            let m = Int(v / 60)
            let s = v - m * 60
            
            self.lblTime.text = String(format: "%d:%02d", m, s)
        }
    }
    
    func liveNew(oneMinuteRespirationRate: Int) {
        DispatchQueue.main.async {
            self.lblOneMinutes.text = "1-minute: \(oneMinuteRespirationRate)"
        }
    }
    
    func liveNew(postureFrame: Int) {
        DispatchQueue.main.async {
            self.displayPostureAnimation(postureFrame)
        }
    }
    
    func liveNew(respirationRate: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.displayRespirationRate(val: respirationRate)
        }
    }
    
    func liveNew(breathCount: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.displayBreathCount(val: breathCount)
        }
    }
    
}
