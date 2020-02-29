//
//  ConnectViewController.swift
//  Prana
//
//  Created by Luccas on 3/14/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth
import Toaster

class ConnectViewController: UIViewController {

    @IBOutlet weak var lbl_success_connect: UILabel!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var lblBatteryWarining: UILabel!
    @IBOutlet weak var lblGuide: UILabel!
    @IBOutlet weak var lblBatteryLevel: UILabel!
    
    var isScanning = false
    var isConnected = false
    var isTutorial = true
    var isBodyMeasurement = false
    
    var tryingTimer: Timer? = nil
    
    var completionHandler: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        initView()
        
        PranaDeviceManager.shared.addDelegate(self)
        
        lblBatteryWarining.isHidden = true
        lbl_success_connect.isHidden = true
        lblBatteryLevel.isHidden = true
        lblGuide.isHidden = false
        
        if isTutorial {
            lblGuide.text = """
            Press and hold the button on Prana for 3 seconds to wirelessly connect to the app.
            """
        } else {
            if isBodyMeasurement {
                lblGuide.text = """
                Press and hold the button on Prana for 3 seconds to wirelessly connect to the app.
                """
            } else {
                lblGuide.text = """
                First wear the device around your body.
                Then press and hold the button on Prana for 3 seconds to wirelessly connect to the app.
                """
            }
        }
        
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
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        PranaDeviceManager.shared.stopGettingLiveData()
        PranaDeviceManager.shared.removeDelegate(self)
        self.dismiss(animated: false) { [unowned self] in
            
            self.completionHandler?()
            
            if self.isTutorial {
                NotificationCenter.default.post(name: .connectViewControllerDidNext, object: nil)
            }
            else {
                NotificationCenter.default.post(name: .connectViewControllerDidNextToSession, object: nil)
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        stopScanPrana()
        stopTryingTimer()
        if PranaDeviceManager.shared.isConnected {
            PranaDeviceManager.shared.stopGettingLiveData()
            PranaDeviceManager.shared.disconnect()
        }
        PranaDeviceManager.shared.removeDelegate(self)
        
        if self.isTutorial {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
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
    
    func startTryingTimer() {
        tryingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (_) in
            PranaDeviceManager.shared.stopGettingLiveData()
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                PranaDeviceManager.shared.startGettingLiveData()
            })
        })
    }
    
    func stopTryingTimer() {
        tryingTimer?.invalidate()
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    func onNewLiveData(_ raw: String) {
        let paras = raw.split(separator: ",")
        
        if paras[0] == "20hz" {
            if paras.count != 7 {
                return
            }
            
            stopTryingTimer()
//            PranaDeviceManager.shared.stopGettingLiveData()
            
            let level = Int(paras[6])!
            processFinal(level)
        }
    }
    
    func processFinal(_ level: Int) {
        if isConnected == true {
            return
        }
        
        lblGuide.isHidden = true
        lbl_success_connect.isHidden = false
        lblBatteryLevel.isHidden = false
        lblBatteryLevel.text = "Battery Level \(level)%"
        
        
        if level < 50 {
            lblBatteryLevel.textColor = UIColor(hexString: "#DE0000")
            lblBatteryWarining.isHidden = false
        }
        else {
            lblBatteryWarining.isHidden = true
        }
        
        isConnected = true
        
        self.btn_next.setBackgroundImage(UIImage(named: "button-green-lg"), for: .normal)
        self.btn_next.isEnabled = true
    }
}

extension ConnectViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidOpenChannel() {
        DispatchQueue.main.async {
            self.startTryingTimer()
        }
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String) {
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
        #if TEST_MODE
        if device.name.contains("Prana Tech")
            || device.name.contains("iPhone")
            || device.name.contains("iPad")
            || device.name.contains("iPod touch") {
            stopScanPrana()
            connectPrana(device)
        }
        #else
        if device.name.contains("Prana Tech") {
            stopScanPrana()
            connectPrana(device)
        }
        #endif
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
//        DispatchQueue.main.async {
//            let toast  = Toast(text: "Prana is connected successfully.", duration: Delay.short)
//            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
//            ToastView.appearance().textColor = .white
//            ToastView.appearance().font = UIFont(name: "Quicksand-Medium", size: 14)
//            toast.show()
//        }
    }
    
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async {
//            self.lblSuccessMessage.textColor = UIColor.black
            self.lbl_success_connect.text = "Failed to connect Prana!"
            self.lbl_success_connect.isHidden = false
            self.lblGuide.isHidden = true
        }
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    
}
