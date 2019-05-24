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
    
    @IBOutlet weak var breathingGraphView: LiveGraph!
    
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var btnBreathSensitivity1: UIButton!
    @IBOutlet weak var btnBreathSensitivity2: UIButton!
    @IBOutlet weak var btnBreathSensitivity3: UIButton!
    @IBOutlet weak var btnPostureSensitivity1: UIButton!
    @IBOutlet weak var btnPostureSensitivity2: UIButton!
    @IBOutlet weak var btnPostureSensitivity3: UIButton!
    
    @IBOutlet weak var lblPostureStateValue: UILabel!
    
    var isLive = false
    
    var objLive: Live?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        objLive = Live()
        objLive?.addDelegate(self)
        breathingGraphView.objLive = objLive
        

        btnBreathSensitivity1.layer.cornerRadius = 8
        btnBreathSensitivity1.clipsToBounds = true
        btnBreathSensitivity1.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnBreathSensitivity2.layer.cornerRadius = 8
        btnBreathSensitivity2.clipsToBounds = true
        btnBreathSensitivity3.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnBreathSensitivity3.layer.cornerRadius = 8
        btnBreathSensitivity3.clipsToBounds = true
        btnBreathSensitivity3.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        
        setBreathSensitivity(val: 2)
        
        btnPostureSensitivity1.layer.cornerRadius = 8
        btnPostureSensitivity1.clipsToBounds = true
        btnPostureSensitivity1.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnPostureSensitivity2.layer.cornerRadius = 8
        btnPostureSensitivity2.clipsToBounds = true
        btnPostureSensitivity2.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        btnPostureSensitivity3.layer.cornerRadius = 8
        btnPostureSensitivity3.clipsToBounds = true
        btnPostureSensitivity3.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        
        setPostureSensitivity(val:2)
        
        startLive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            objLive?.removeDelegate(self)
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
        
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    @IBAction func onSetUprightClick(_ sender: UIButton) {
        objLive?.learnUprightAngleHandler()
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
        
        objLive?.setBreathingResponsiveness(val: val)
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
        
        objLive?.setPostureResponsiveness(val: val)
    }
    
    @IBAction func onPostureSensitivityChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    func displayPostureStatusValue(x: Int) {
        lblPostureStateValue.text = "\(x)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        objLive?.removeDelegate(self)
        stopLive()
    }
}

extension TutorialLowerbackViewController: LiveDelegate {
    func liveProcess(sensorData: [Double]) {
        
    }
    
    func liveDebug(para1: String, para2: String, para3: String, para4: String) {
        
    }
    
    func liveNewBreathingCalculated() {
        
    }
    
    func liveNewPostureCalculated() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.displayPostureStatusValue(x: self.objLive?.whichPostureFrame ?? 0)
        }
    }
    
    func liveNewRespRateCaclculated() {
        
    }
    
    func liveDidUprightSet() {
        
    }
    
    
    
}
