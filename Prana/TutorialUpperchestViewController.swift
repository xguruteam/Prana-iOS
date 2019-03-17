//
//  TutorialUpperchestViewController.swift
//  Prana
//
//  Created by Luccas on 3/15/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class TutorialUpperchestViewController: UIViewController {
    
    @IBOutlet weak var breathingGraphView: BreathingGraph!
    
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var slidBreathResponsiveness: UISlider!
    @IBOutlet weak var lblBreathResponsiveness: UILabel!
    @IBOutlet weak var slidPostureResponsiveness: UISlider!
    @IBOutlet weak var lblPostureResponsiveness: UILabel!
    @IBOutlet weak var lblPostureStateValue: UILabel!
    
    var isLive = false
    var seconds: Int = 62
    var timer: Timer?
    var buff: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PranaDeviceManager.shared.addDelegate(self)
        startTimer()
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
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        breathingGraphView.initGraph()
        breathingGraphView.setTutorialUCView(view: self)
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    @IBAction func onSetUprightClick(_ sender: UIButton) {
        breathingGraphView.learnUprightAngleHandler()
    }
    
    @IBAction func onSliderBreathResponsivenessChange(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        lblBreathResponsiveness.text = "\(value)"
        breathingGraphView.setBreathingResponsiveness(val: value)
    }
    
    @IBAction func onSliderPostureResponsivenessChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        lblPostureResponsiveness.text = "\(value)"
        breathingGraphView.setPostureResponsiveness(val: value)
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

extension TutorialUpperchestViewController: PranaDeviceManagerDelegate {
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
