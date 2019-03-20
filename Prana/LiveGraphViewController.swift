//
//  LiveGraphViewController.swift
//  Prana
//
//  Created by Luccas on 3/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth

class LiveGraphViewController: UIViewController {

    @IBOutlet weak var btStartStop: UIButton!
    @IBOutlet weak var breathingGraphView: BreathingGraph!
    @IBOutlet weak var postureIndicatorView: PostureIndicator!
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var btnBreathSensitivity1: UIButton!
    @IBOutlet weak var btnBreathSensitivity2: UIButton!
    @IBOutlet weak var btnBreathSensitivity3: UIButton!
    @IBOutlet weak var btnPostureSensitivity1: UIButton!
    @IBOutlet weak var btnPostureSensitivity2: UIButton!
    @IBOutlet weak var btnPostureSensitivity3: UIButton!
    @IBOutlet weak var lblRespirationRate: UILabel!
    @IBOutlet weak var lblBreathCount: UILabel!
    @IBOutlet weak var lblDebugLine1: UILabel!
    @IBOutlet weak var lblDebugLine2: UILabel!
    @IBOutlet weak var lblDebugLine3: UILabel!
    @IBOutlet weak var lblDebugLine4: UILabel!
    
    var isLive = false
    
    var buff: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PranaDeviceManager.shared.addDelegate(self)
        
        btnBreathSensitivity1.layer.cornerRadius = 8
        btnBreathSensitivity1.clipsToBounds = true
        btnBreathSensitivity1.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnBreathSensitivity2.layer.cornerRadius = 8
        btnBreathSensitivity2.clipsToBounds = true
        btnBreathSensitivity3.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnBreathSensitivity3.layer.cornerRadius = 8
        btnBreathSensitivity3.clipsToBounds = true
        btnBreathSensitivity3.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        
        setBreathSensitivity(val: 1)
        
        btnPostureSensitivity1.layer.cornerRadius = 8
        btnPostureSensitivity1.clipsToBounds = true
        btnPostureSensitivity1.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnPostureSensitivity2.layer.cornerRadius = 8
        btnPostureSensitivity2.clipsToBounds = true
        btnPostureSensitivity2.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnPostureSensitivity3.layer.cornerRadius = 8
        btnPostureSensitivity3.clipsToBounds = true
        btnPostureSensitivity3.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        
        setPostureSensitivity(val: 1)
    }
    
    
    
    @IBAction func onStartStop(_ sender: Any) {
        if isLive {
            stopLive()
        }
        else {
            if !PranaDeviceManager.shared.isConnected {
                let alert = UIAlertController(title: "Prana", message: "No Prana Device is connected. Please Search and connect", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            startLive()
        }
    }
    
    @IBAction func onUpright(_ sender: Any) {
        breathingGraphView.learnUprightAngleHandler()
//        btnUpright.isEnabled = false
    }
    
    @IBAction func onBack(_ sender: Any) {
        PranaDeviceManager.shared.removeDelegate(self)
        stopLive()
        self.dismiss(animated: true, completion: nil)
    }
    
    func startLive() {
        isLive = true
        breathingGraphView.initGraph()
        breathingGraphView.setViews(lgview: self, piview: postureIndicatorView)
        self.btStartStop.setTitle("Stop", for: .normal)
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        isLive = false
        self.btStartStop.setTitle("Start", for: .normal)
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    func onNewLiveData(_ raw: String) {
        let paras = raw.split(separator: ",")

        if paras[0] == "20hz" {
            if paras.count != 7 {
                return
            }
            var data: [Double] = []
            data.append(0.0)
            data.append(Double(paras[1])!)
            data.append(Double(paras[2])!)
            data.append(Double(paras[3])!)
            data.append(Double(paras[4])!)
            data.append(Double(paras[5])!)
            data.append(0.0)
            
            breathingGraphView.processBreathingPosture(sensorData: data)
        }
        else if paras[0] == "Upright" {
            if paras.count != 4 {
                return
            }
            var data: [Double] = []
            data.append(0.0)
            data.append(Double(paras[1])!)
            data.append(Double(paras[2])!)
            data.append(Double(paras[3])!)
            breathingGraphView.setUprightButtonPush(sensorData: data)
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
        
        breathingGraphView.setBreathingResponsiveness(val: val)
    }
    
    @IBAction func onBreathSensitivityChange(_ sender: UIButton) {
        setBreathSensitivity(val: sender.tag)
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
        
        breathingGraphView.setPostureResponsiveness(val: val)
    }
    
    @IBAction func onPostureSensitivityChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is DevicesViewController {
            print("is going device view controller")
            stopLive()
        }
    }
    
    func displayRespirationRate(val: Double) {
        lblRespirationRate.text = String(val)
    }
    
    func displayBreathCount(val: Int) {
        lblBreathCount.text = String(val)
    }
    
    func displayDebugStats(ln1: String, ln2: String, ln3: String, ln4: String) {
        lblDebugLine1.text = ln1
        lblDebugLine2.text = ln2
        lblDebugLine3.text = ln3
        lblDebugLine4.text = ln4
    }

}


extension LiveGraphViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidOpenChannel() {
        
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
        
    }
    
    func PranaDeviceManagerDidStartScan() {
        
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        
    }
    
    func PranaDeviceManagerFailConnect() {
        
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
        guard let data  = String(data: parameter.value!, encoding: .utf8) else {
            return
        }
        
        if data.starts(with: "20hz,") || data.starts(with: "Upright,") {
            if let raw = buff {
                DispatchQueue.main.async { [weak self] in
                    self?.onNewLiveData(raw)
                }
            }
            
            buff = data
        }
        else {
            if let _ = buff {
                buff = buff! + data
            }
            else {
                buff = data
            }
        }
        
    }
    
}
