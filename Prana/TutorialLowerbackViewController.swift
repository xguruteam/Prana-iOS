//
//  TutorialLowerbackViewController.swift
//  Prana
//
//  Created by Luccas on 3/14/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class TutorialLowerbackViewController: UIViewController {
    
    @IBOutlet weak var breathingGraphView: BreathingGraph!
    
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var btnBreathSensitivity1: UIButton!
    @IBOutlet weak var btnBreathSensitivity2: UIButton!
    @IBOutlet weak var btnBreathSensitivity3: UIButton!
    @IBOutlet weak var btnPostureSensitivity1: UIButton!
    @IBOutlet weak var btnPostureSensitivity2: UIButton!
    @IBOutlet weak var btnPostureSensitivity3: UIButton!
    
    @IBOutlet weak var lblPostureStateValue: UILabel!
    
    var isLive = false
    var seconds: Int = 62
    var timer: Timer?
    var buff: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PranaDeviceManager.shared.addDelegate(self)
        startTimer()
        
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func countTime() {
        self.seconds -= 1
        if self.seconds == 60 {
            startLive()
        } else if self.seconds == 0 {
            stopTimer()
            stopLive()
        }
    }
    
    func startLive() {
        if !PranaDeviceManager.shared.isConnected {
            let alert = UIAlertController(title: "Prana", message: "No Prana Device is connected. Please Search and connect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        breathingGraphView.initGraph()
        breathingGraphView.setTutorialLBView(view: self)
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    @IBAction func onSetUprightClick(_ sender: UIButton) {
        breathingGraphView.learnUprightAngleHandler()
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
        } else if paras[0] == "Upright" {
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
    
    func displayPostureStatusValue(x: Int) {
        lblPostureStateValue.text = "\(x)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        stopTimer()
        stopLive()
    }
}

extension TutorialLowerbackViewController: PranaDeviceManagerDelegate {
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
