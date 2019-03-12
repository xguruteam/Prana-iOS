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
    @IBOutlet weak var slidBreathResponsiveness: UISlider!
    @IBOutlet weak var lblBreathResponsiveness: UILabel!
    @IBOutlet weak var slidPostureResponsiveness: UISlider!
    @IBOutlet weak var lblPostureResponsiveness: UILabel!
    @IBOutlet weak var lblRespirationRate: UILabel!
    @IBOutlet weak var lblBreathCount: UILabel!
    
    var isLive = false
    
    var buff: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PranaDeviceManager.shared.addDelegate(self)
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
    
    @IBAction func onSliderBreathResponsivenessChanged(_ sender: UISlider) {
//        lblBreathResponsiveness.text = String.
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

}


extension LiveGraphViewController: PranaDeviceManagerDelegate {
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
