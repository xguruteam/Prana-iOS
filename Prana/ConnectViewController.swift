//
//  ConnectViewController.swift
//  Prana
//
//  Created by Guru on 3/14/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectViewController: UIViewController {

    @IBOutlet weak var lblSuccessMessage: UILabel!
    @IBOutlet weak var lblBatteryWarning: UILabel!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var lblConnectState: UILabel!
    @IBOutlet weak var lblBatteryLevel: UILabel!
    
    
    var isScanning = false
    var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lblSuccessMessage.isHidden = true
        lblBatteryWarning.isHidden = true
        btNext.isEnabled = false
        btNext.alpha = 0.5
        lblConnectState.text = "Off"
        lblBatteryLevel.text = "?%"
        
        PranaDeviceManager.shared.delegate = self
        PranaDeviceManager.shared.addDelegate(self)
        
        startScanPrana()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            stopScanPrana()
            if PranaDeviceManager.shared.isConnected {
                PranaDeviceManager.shared.stopGettingLiveData()
                PranaDeviceManager.shared.disconnect()
                PranaDeviceManager.shared.removeDelegate(self)
                PranaDeviceManager.shared.delegate = nil
            }
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        PranaDeviceManager.shared.removeDelegate(self)
        NotificationCenter.default.post(name: .connectViewControllerDidNext, object: nil)
    }
    
    func startScanPrana() {
        isScanning = true
        
        
        PranaDeviceManager.shared.startScan()
    }
    
    func stopScanPrana() {
        guard isScanning else {
            return
        }
        
        isScanning = false
        PranaDeviceManager.shared.stopScan()
        
    }
    
    func connectPrana(_ device: PranaDevice) {
        PranaDeviceManager.shared.connectTo(device.peripheral)
    }
    
    func onNewLiveData(_ raw: String) {
        let paras = raw.split(separator: ",")
        
        if paras[0] == "20hz" {
            if paras.count != 7 {
                return
            }
            
            PranaDeviceManager.shared.stopGettingLiveData()
            
            let level = Int(paras[6])!
            processFinal(level)
        }
    }
    
    func processFinal(_ level: Int) {
        if isConnected == true {
            return
        }
        
        isConnected = true
        
        self.lblConnectState.text = "On"
        self.lblBatteryLevel.text = "\(level)%"
        
        if level < 60 {
            self.lblBatteryWarning.layer.borderWidth = 1
            self.lblBatteryWarning.layer.borderColor = UIColor.red.cgColor
            self.lblBatteryWarning.isHidden = false
            return
        }
        
        self.btNext.isEnabled = true
        self.btNext.alpha = 1.0
        
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

extension ConnectViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidOpenChannel() {
        self.lblSuccessMessage.isHidden = false
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
        DispatchQueue.main.async {
            self.onNewLiveData(data)
        }
    }
    
    func PranaDeviceManagerDidStartScan() {
        
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        print(device.name)
        if device.name.contains("Prana Tech") || device.name.contains("iPod touch") {
            stopScanPrana()
            connectPrana(device)
        }
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        
    }
    
    func PranaDeviceManagerFailConnect() {
        self.lblSuccessMessage.textColor = UIColor.black
        self.lblSuccessMessage.text = "Failed to connect Prana!"
        self.lblSuccessMessage.isHidden = false
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    
}
