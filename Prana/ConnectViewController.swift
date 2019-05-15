//
//  ConnectViewController.swift
//  Prana
//
//  Created by Luccas on 3/14/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectViewController: UIViewController {

    @IBOutlet weak var lbl_success_connect: UILabel!
    @IBOutlet weak var btn_next: UIButton!
    
    var isScanning = false
    var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
        
        PranaDeviceManager.shared.delegate = self
        PranaDeviceManager.shared.addDelegate(self)
        
        startScanPrana()
    }
    
    func initView() {
        let background = UIImage(named: "app-background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.insertSubview(imageView, at: 0)
        view.sendSubviewToBack(imageView)
        
        lbl_success_connect.isHidden = true
        btn_next.isEnabled = false
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
        PranaDeviceManager.shared.delegate = nil
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .connectViewControllerDidNext, object: nil)
        }
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
        
//        if level < 60 {
//            return
//        }
        
        self.lbl_success_connect.isHidden = false
        self.btn_next.setBackgroundImage(UIImage(named: "button-green-lg"), for: .normal)
        self.btn_next.isEnabled = true
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
//        DispatchQueue.main.async {
            PranaDeviceManager.shared.startGettingLiveData()
//        }
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
//        DispatchQueue.main.async {
            self.onNewLiveData(data)
//        }
    }
    
    func PranaDeviceManagerDidStartScan() {
        
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        print(device.name)
        if device.name.contains("Prana Tech")
        || device.name.contains("iPod touch") {
            stopScanPrana()
            connectPrana(device)
        }
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        
    }
    
    func PranaDeviceManagerFailConnect() {
//        DispatchQueue.main.async {
//            self.lblSuccessMessage.textColor = UIColor.black
            self.lbl_success_connect.text = "Failed to connect Prana!"
            self.lbl_success_connect.isHidden = false
//        }
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    
}
