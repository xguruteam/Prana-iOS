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

class BodyMeasurementsViewController: SuperViewController {

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
    var note: String?
    
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
            case .select:
                btnStart.isHidden = true
                btnTake.isHidden = true
            case .take:
                btnStart.isHidden = true
                btnTake.isHidden = false
            }
        }
    }
    
    let statuses = [
        "Fully retract the belt, then tap Start Measurement.",
        "Tap the body area to measure.",
        "Wrap belt around body area and tap Take Measurement.",
        "To change body area, tap Restart.",
    ]
    
    var status: Int = 0 {
        didSet {
            updateStatus()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnStart.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        adjustButtons()
        status = 0
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let todayMeasurement = dataController.fetchDailyMeasurement(date: Date()) {
            measurements = todayMeasurement.data
            note = todayMeasurement.note
            updateMeasurementValues()
        }
        
        PranaDeviceManager.shared.addDelegate(self)
        batteryStatus.isEnabled = PranaDeviceManager.shared.isConnected
        
        reset()
        status = 0
        
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
    
    func setupButton(button: BMButton) {
        var buttonWidth: CGFloat = 60.0
        let buttonHeight: CGFloat = 28.0
        
        let title = button.position
        
        if title.count > 7 {
            buttonWidth = 85
        }
        
        bodyContainer.addSubview(button)
        button.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
        
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }
    
    
    func adjustButtons() {
        var button = buttons[.neck]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 60.0).isActive = true
        
        button = buttons[.shoulders]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 92.0).isActive = true
        
        button = buttons[.chest]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 122.0).isActive = true
        
        button = buttons[.waist]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 186.0).isActive = true
        
        button = buttons[.hips]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 226.0).isActive = true
        
        button = buttons[.larm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -66.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 140.0).isActive = true
        
        button = buttons[.lfarm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -86.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 186.0).isActive = true
        
        button = buttons[.lwrist]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -76.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 230.0).isActive = true
        
        button = buttons[.rarm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 66.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 140.0).isActive = true
        
        button = buttons[.rfarm]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 86.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 186.0).isActive = true
        
        button = buttons[.rwrist]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 76.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 230.0).isActive = true
        
        button = buttons[.lthigh]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -32.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 280.0).isActive = true
        
        button = buttons[.lcalf]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -35.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 358.0).isActive = true
        
        button = buttons[.rthigh]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 32.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 280.0).isActive = true
        
        button = buttons[.rcalf]!
        setupButton(button: button)
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: 35.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 358.0).isActive = true
        
        button = buttons[.custom1]!
        setupButton(button: button)
        button.isSelected = true
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -125.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 360).isActive = true
        
        button = buttons[.custom2]!
        setupButton(button: button)
        button.isSelected = true
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -125.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 400).isActive = true
        
        button = buttons[.custom3]!
        setupButton(button: button)
        button.isSelected = true
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor, constant: -125.0).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 440).isActive = true
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
        objLive?.stopMode()
        objLive = nil
    }
    
    func startLive() {
        if isLive == true { return }
        
        isLive = true
        objLive?.startMode()
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        if isLive == false { return }
        
        isLive = false
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    func reset() {
        self.position = nil
        step = .ready
    }
    
    func unselectAllButtons() {
        buttons.forEach { (key, button) in
            button.isSelected = false
        }
    }
    
    func updateMeasurementValues() {
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

        saveToLocalDB()
    }
    
    func saveToLocalDB() {
        let object = Measurement(date: Date(), note: note, data: measurements)
        dataController.addRecord(body: object)
    }
    
    func applyUnit(original: Float) -> Float {
        let newValue = ((unit == 0) ? original : (original * 2.54))
        return Float(round(newValue * 100) / 100.0)
    }
    
    func gotoConnectViewController() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ConnectViewController") as! ConnectViewController
        firstVC.isTutorial = false
        firstVC.completionHandler = { [unowned self] in
            self.startLive()
            self.gotoSelectStep()
        }
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func gotoSelectStep() {
        guard step == .ready else { return }
        
        objBody?.start()
        
        step = .select
        
        status = 1
    }
    
    @objc func onConnectViewControllerNextToSession() {
        gotoSelectStep()
    }
        
    @objc func onButtonClick(_ sender: BMButton) {
        switch step {
        case .ready:
            status = 0
        case .select:
            status = 2
        case .take:
            status = 3
        }
        
        guard step == .select else {
            return
        }
        
        let title = sender.position
        self.position = BMPosition(rawValue: title)
        btnStart.isHidden = true
        btnTake.isHidden = false
    }
    
    @IBAction func onStart(_ sender: Any) {
        if PranaDeviceManager.shared.isConnected == false || isLive == false {
            gotoConnectViewController()
            return
        }
        
        gotoSelectStep()
    }
    
    
    @IBAction func onTake(_ sender: Any) {
        guard let position = position else {
            status = 1
            return
        }
        
        let button = buttons[position]
        button?.value = 0
        
        step = .take
        if status != 2 {
            status = 2
        }
        
        objBody?.stop()
    }
    
    @IBAction func onHelp(_ sender: Any) {

    }
    
    @IBAction func onReset(_ sender: Any) {
        reset()
        status = 0
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
        
        updateMeasurementValues()
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let target = segue.destination as? DiaryViewController {
            target.date = Date()
            target.note = note
            target.noteChangeHandler = { [unowned self] newNote in
                self.note = newNote
                self.saveToLocalDB()
            }
        }
    }

}

extension BodyMeasurementsViewController: BodyDelegate {
    func bodyDidCalculateDistance(distance: Double) {
        DispatchQueue.main.async {
            self.updateMeasurement(measurement: Float(distance))
        }
    }
}


extension BodyMeasurementsViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        DispatchQueue.main.async {
            self.batteryStatus.isEnabled = true
        }
    }
    
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async {
            self.batteryStatus.isEnabled = false
            self.reset()
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
}
