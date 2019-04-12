//
//  ConnectionTestViewController.swift
//  Prana
//
//  Created by Luccas on 3/21/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectionTestViewController: UIViewController {

    @IBOutlet weak var logView: UITextView!
    
    var log: String = "Log" {
        didSet {
            DispatchQueue.main.async {
                self.logView.text = self.log
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        log += "\n"
        log += "viewDidLoad\n"
        
        PranaDeviceManager.shared.delegate = self
        PranaDeviceManager.shared.addDelegate(self)
        
        log += "startScan\n"
        PranaDeviceManager.shared.startScan()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        log += "onSearch\n"
        
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "DevicesViewController")
        self.navigationController?.pushViewController(firstVC, animated: true)
    }
    
    @IBAction func onSendManually(_ sender: Any) {
        log += "start20hzManually\n"
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func onNewLiveData(_ raw: String) {
        log += "onNewLiveData\n"
        let paras = raw.split(separator: ",")
        
        if paras[0] == "20hz" {
            if paras.count != 7 {
                return
            }
            log += "stopData\n"
            PranaDeviceManager.shared.stopGettingLiveData()
            
//            let level = Int(paras[6])!
//            processFinal(level)
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

extension ConnectionTestViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidStartScan() {
        log += "didStartScan\n"
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        log += "didStopScan: \(error)\n"
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        log += "detectedDevice: \(device.name)\n"
        if device.name.contains("Prana Tech")
            || device.name.contains("iPod touch")
            || device.name.contains("PranaTech") {
            log += "stopScan"
            PranaDeviceManager.shared.stopScan()
            log += "connect: \(device.name)\n"
            PranaDeviceManager.shared.connectTo(device.peripheral)
        }
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        log += "device connected!\n"
    }
    
    func PranaDeviceManagerFailConnect() {
        log += "device failed to connect!\n"
    }
    
    func PranaDeviceManagerDidOpenChannel() {
        log += "channel opened\n"
        log += "start20hzAutomatically\n"
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
        log += "didReceive: \(data)\n"
        DispatchQueue.main.async {
            print(data)
            self.onNewLiveData(data)
        }
    }
    
    
}
