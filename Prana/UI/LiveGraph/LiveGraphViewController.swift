//
//  LiveGraphViewController.swift
//  Prana
//
//  Created by Luccas on 4/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth
import Toaster

class LiveGraphViewController: SuperViewController {
    
    @IBOutlet weak var breathingGraphView: LiveGraph!
    @IBOutlet weak var breathSensitivityGroup: UIView!
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var breathButtonGroup: RadioGroupButton!
    
    @IBOutlet weak var lblRespirationRate: UILabel!
    @IBOutlet weak var lblBreathCount: UILabel!
    @IBOutlet weak var lblOneMinutes: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lbSessionAvg: UILabel!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    
    @IBOutlet weak var postureSensitivityGroup: UIView!
    
    @IBOutlet weak var postureButtonGroup: RadioGroupButton!
    
    @IBOutlet weak var btnWearLowerBack: UIButton!
    @IBOutlet weak var btnWearUpperChest: UIButton!
    
    @IBOutlet weak var batteryView: BatteryStateView!
    
    @IBOutlet weak var liveGraphHeight: NSLayoutConstraint!
    
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    var isLive = false
    var objLive: Live?
    var isLowerBack = true
    var isFinish = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        initView()
        
        PranaDeviceManager.shared.addDelegate(self)
        
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
        lblOneMinutes.text = "0"
        
        setWearPosition(val: 0)
        
        startLive()
        
        batteryView.isGray = true
        
        adjustContraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFinish { return }
        stopLive()
    }
    
    func initView() {        
        postureButtonGroup.delegate = self
        breathButtonGroup.delegate = self
        
        btnWearLowerBack.titleLabel?.textAlignment = .center
        btnWearUpperChest.titleLabel?.textAlignment = .center

//        btnUpright.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        btnUpright.isHighlighted = false
    }
    
    func adjustContraints() {
        if UIScreen.main.nativeBounds.height >= 1920 { // above 8 plus
            liveGraphHeight.constant = 150
            buttonHeight.constant = 100
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        isFinish = true
        stopLive()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
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
        
        PranaDeviceManager.shared.removeDelegate(self)
    }
    
    func setBreathSensitivity(val: Int) {
        breathButtonGroup.selectedIndex = val
        dataController.sensitivities.lgbr = val - 1
        dataController.saveSettings()
        
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        postureButtonGroup.selectedIndex = val
        dataController.sensitivities.lgps = val - 1
        dataController.saveSettings()

        objLive?.setPostureResponsiveness(val: val)
    }
    
    func setWearPosition(val: Int) {
        if val == 0 {
            btnWearLowerBack.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)
            btnWearLowerBack.setTitleColor(UIColor.white, for: .normal)
            btnWearLowerBack.setImage(#imageLiteral(resourceName: "ic_lower_back_white"), for: .normal)
            
            btnWearUpperChest.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            btnWearUpperChest.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4392156863, blue: 0.5254901961, alpha: 1), for: .normal)
            btnWearUpperChest.setImage(#imageLiteral(resourceName: "ic_upper_chest_grey"), for: .normal)
            
            isLowerBack = true
        } else {
            btnWearLowerBack.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            btnWearLowerBack.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4392156863, blue: 0.5254901961, alpha: 1), for: .normal)
            btnWearLowerBack.setImage(#imageLiteral(resourceName: "ic_lower_back_grey"), for: .normal)
            
            btnWearUpperChest.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)
            btnWearUpperChest.setTitleColor(UIColor.white, for: .normal)
            btnWearUpperChest.setImage(#imageLiteral(resourceName: "ic_upper_chest_white"), for: .normal)
            isLowerBack = false
        }
        
        displayPostureAnimation(1)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        let frame = whichFrame
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

extension LiveGraphViewController: RadioGroupButtonDelegate {
    func onSelectedIndex(index: Int, sender: RadioGroupButton) {
        if sender.tag == 1 {
            setBreathSensitivity(val: index)
        } else {
            setPostureSensitivity(val: index)
        }
    }
}

extension LiveGraphViewController: LiveDelegate {
    
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.batteryView.progress = CGFloat(sensorData[6]) / 100.0
            
            let v = Int(timeElapsed)
            let m = Int(v / 60)
            let s = v - m * 60
            
            self.lblTime.text = String(format: "%d:%02d", m, s)
        }
    }
    
    func liveNew(oneMinuteRespirationRate: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.lblOneMinutes.text = "\(oneMinuteRespirationRate)"
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
    
    func liveNew(sessionAvgRate: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.lbSessionAvg.text = "\(sessionAvgRate)"
        }
    }
    
    func liveUprightHasBeenSet() {
        DispatchQueue.main.async {
//            self.btnUpright.setTitle("SET UPRIGHT ✅", for: .normal)
        }
    }
}

extension LiveGraphViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.isFinish = true
            self.stopLive()
            self.batteryView.progress = 0
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
}
