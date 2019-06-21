//
//  BodyMeasurementsViewController.swift
//  Prana
//
//  Created by Guru on 6/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Toaster
import CoreBluetooth

enum BMSteps {
    case ready
    case select
    case take
}

enum BMPosition: String {
    case neck = "NECK"
    case shoulders = "SHOULDERS"
    case chest = "CHEST"
    case waist = "WAIST"
    case hips = "HIPS"
    case larm = "LEFT ARM"
    case lfarm = "L FOREARM"
    case lwrist = "L WRIST"
    case rarm = "RIGHT ARM"
    case rfarm = "R FOREARM"
    case rwrist = "R WRIST"
    case lthigh = "L THIGH"
    case lcalf = "L CALF"
    case rthigh = "R THIGH"
    case rcalf = "R CALF"
    case custom1 = "CUSTOM 1"
    case custom2 = "CUSTOM 2"
    case custom3 = "CUSTOM 3"
}

class BodyMeasurementsViewController: UIViewController {

    @IBOutlet weak var bodyContainer: UIView!
    @IBOutlet weak var batteryStatus: BluetoothStateView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnTake: UIButton!
    @IBOutlet weak var btnUnit: PranaButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    var unit: Int = 0
    
    var objLive: Live?
    var objBody: Body?
    
    var isLive = false
    
    let buttons: [BMPosition: BMButton] = [
        .neck: BMButton(position: BMPosition.neck.rawValue),
        .shoulders: BMButton(position: BMPosition.shoulders.rawValue),
        .chest: BMButton(position: BMPosition.chest.rawValue),
        .waist: BMButton(position: BMPosition.waist.rawValue),
        .hips: BMButton(position: BMPosition.hips.rawValue),
        .larm: BMButton(position: BMPosition.larm.rawValue),
        .lfarm: BMButton(position: BMPosition.lfarm.rawValue),
        .lwrist: BMButton(position: BMPosition.lwrist.rawValue),
        .rarm: BMButton(position: BMPosition.rarm.rawValue),
        .rfarm: BMButton(position: BMPosition.rfarm.rawValue),
        .rwrist: BMButton(position: BMPosition.rwrist.rawValue),
        .lthigh: BMButton(position: BMPosition.lthigh.rawValue),
        .lcalf: BMButton(position: BMPosition.lcalf.rawValue),
        .rthigh: BMButton(position: BMPosition.rthigh.rawValue),
        .rcalf: BMButton(position: BMPosition.rcalf.rawValue),
        .custom1: BMButton(position: BMPosition.custom1.rawValue),
        .custom2: BMButton(position: BMPosition.custom2.rawValue),
        .custom3: BMButton(position: BMPosition.custom3.rawValue),
    ]
    
    var measurements: [BMPosition: Float] = [:]
    
    var position: BMPosition? {
        didSet {
            if let oldValue = oldValue {
                let oldButton = buttons[oldValue]
                oldButton?.isSelected = false
            }
            
            guard let position = position else { return }
            
            let newButton = buttons[position]
            newButton?.isSelected = true
        }
    }
    
    var step: BMSteps = .ready {
        didSet {
            switch step {
            case .ready:
                btnStart.isHidden = false
                btnTake.isHidden = true
                status = 0
            case .select:
                btnStart.isHidden = true
                btnTake.isHidden = false
                status = 1
            default:
                break
            }
        }
    }
    
    let statuses = [
        "Fully retract the belt, then tap Start Measurement.",
        "Tap the body area to measure.",
        "Wrap and lock belt around chosen body area.",
        "Tap Take Measurement.",
    ]
    
    var status: Int = 0 {
        didSet {
            updateStatus()
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        var button = buttons[.neck]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 62.0).isActive = true
        
        button = buttons[.shoulders]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 92.0).isActive = true
        
        button = buttons[.chest]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 118.0).isActive = true
        
        button = buttons[.waist]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 186.0).isActive = true
        
        button = buttons[.hips]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 216.0).isActive = true
        
        button = buttons[.larm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -60.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 140.0).isActive = true
        
        button = buttons[.lfarm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -70.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 186.0).isActive = true
        
        button = buttons[.lwrist]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -76.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 220.0).isActive = true
        
        button = buttons[.rarm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 60.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 140.0).isActive = true
        
        button = buttons[.rfarm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 70.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 186.0).isActive = true
        
        button = buttons[.rwrist]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 76.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 220.0).isActive = true
        
        button = buttons[.lthigh]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -26.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 280.0).isActive = true
        
        button = buttons[.lcalf]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -30.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 358.0).isActive = true
        
        button = buttons[.rthigh]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 26.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 280.0).isActive = true
        
        button = buttons[.rcalf]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 30.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 358.0).isActive = true
        
        button = buttons[.custom1]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -140.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 360).isActive = true
        
        button = buttons[.custom2]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -140.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 400).isActive = true
        
        button = buttons[.custom3]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -140.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 440).isActive = true
        
        
        status = 0
    }
    
    func setupButton(button: BMButton) {
        let buttonWidth: CGFloat = 50.0
        let buttonHeight: CGFloat = 25.0
        
        bodyContainer.addSubview(button)
        button.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
        
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PranaDeviceManager.shared.addDelegate(self)
        batteryStatus.isEnabled = PranaDeviceManager.shared.isConnected
        
        reset()
        
        initLive()
        
        if PranaDeviceManager.shared.isConnected {
            startLive()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isLive {
            stopLive()
        }
        
        deinitLive()
        
        PranaDeviceManager.shared.removeDelegate(self)
    }
    
    func updateStatus() {
        lblStatus.text = statuses[status]
        lblStatus.alpha = 0
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.lblStatus.alpha = 1.0
        }
    }
    
    func initLive() {
        objLive = Live()
        objLive?.appMode = 5
        
        objBody = Body(live: objLive!)
        objBody?.delegate = self
        
        isLive = false
    }
    
    func deinitLive() {
        objBody?.delegate = nil
        objBody = nil
        objLive = nil
    }
    
    func startLive() {
        if isLive == true { return }
        
        isLive = true
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        if isLive == false { return }
        
        isLive = false
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    func reset() {
        self.position = nil
//        unselectAllButtons()
        step = .ready
    }
    
    func unselectAllButtons() {
        buttons.forEach { (key, button) in
            button.isSelected = false
        }
    }
    
    func changeMeasurementUnit() {
        buttons.forEach { (key, button) in
            guard let measurement = measurements[key] else { return }
            button.value = applyUnit(original: measurement)
        }
    }
    
    func updateMeasurement(measurement: Float) {
        guard let position = position else {
            return
        }
        
        guard step == .take else { return }
        
        let button = buttons[position]
        button?.value = applyUnit(original: measurement)
        
        measurements[position] = measurement
    }
    
    func applyUnit(original: Float) -> Float {
        let newValue = (unit == 0) ? original : (original / 2.54)
        return Float(round(newValue * 100) / 100.0)
    }
    
    func gotoConnectViewController() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ConnectViewController") as! ConnectViewController
        firstVC.isTutorial = false
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc func onButtonClick(_ sender: BMButton) {
        guard step == .select else {
            
            updateStatus()
            
//            var message = ""
//            if step == .take {
//                message = "Please try from start again. Press Referesh button."
//            }
//            else {
//                message = "Please press Start Measurement button first."
//            }
//            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let title = sender.position
        self.position = BMPosition(rawValue: title)
        status = 2
    }
    
    @IBAction func onStart(_ sender: Any) {
        
        if PranaDeviceManager.shared.isConnected == false || isLive == false {
            gotoConnectViewController()
            return
        }
        guard step == .ready else { return }
        
        objBody?.start()
        
        step = .select
    }
    
    @IBAction func onTake(_ sender: Any) {
        guard let position = position else {
            
            updateStatus()
//            let alert = UIAlertController(title: nil, message: "Please select Position.", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard step == .select else { return }

        let button = buttons[position]
        button?.value = 0
        
        step = .take
        
        objBody?.stop()
    }
    
    @IBAction func onHelp(_ sender: Any) {
//        let vc = Utils.getStoryboardWithIdentifier(identifier: "HelpBodyMeasurementsViewController") as! HelpBodyMeasurementsViewController
    }
    
    @IBAction func onReset(_ sender: Any) {
        reset()
    }
    
    @IBAction func onEdit(_ sender: Any) {
    }
    
    @IBAction func onChangeUnit(_ sender: Any) {
        if unit == 0 {
            unit = 1
            btnUnit.setTitle("Cms", for: .normal)
        }
        else {
            unit = 0
            btnUnit.setTitle("Inches", for: .normal)
        }
        
        changeMeasurementUnit()
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

extension BodyMeasurementsViewController: BodyDelegate {
    func bodyDidCalculateDistance(distance: Double) {
        DispatchQueue.main.async {
            self.updateMeasurement(measurement: Float(distance))
        }
    }
}


extension BodyMeasurementsViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidStartScan() {
        
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        DispatchQueue.main.async {
            self.batteryStatus.isEnabled = true
        }
    }
    
    func PranaDeviceManagerFailConnect() {
        DispatchQueue.main.async {
            self.batteryStatus.isEnabled = false
            self.reset()
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont(name: "Quicksand-Medium", size: 14)
            toast.show()
        }
    }
    
    func PranaDeviceManagerDidOpenChannel() {
        
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
        
    }
    
    
}
