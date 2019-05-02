//
//  LiveFeedViewController.swift
//  Prana
//
//  Created by Guru on 4/16/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Macaw

class LiveFeedViewController: UIViewController {
    
    @IBOutlet weak var breathingGraphView: LiveGraph!
    
    @IBOutlet weak var breathSensitivityGroup: UIView!
    @IBOutlet weak var btnUpright: UIButton!

    @IBOutlet weak var btnBreathSensitivityRadio1: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle1: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio2: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle2: UIButton!
    @IBOutlet weak var btnBreathSensitivityRadio3: UIButton!
    @IBOutlet weak var btnBreathSensitivityTitle3: UIButton!
    
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    
    @IBOutlet weak var postureSensitivityGroup: UIView!
    @IBOutlet weak var btnPostureSensitivityRadio1: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle1: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio2: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle2: UIButton!
    @IBOutlet weak var btnPostureSensitivityRadio3: UIButton!
    @IBOutlet weak var btnPostureSensitivityTitle3: UIButton!
    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    var isLive = false
    var objLive: Live?
    var isLowerBack = true
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        if isLowerBack {
            lblDescription.text = "Sit upright and tap below to set your upright posture. You can also double-press the device button."
        }
        else {
            lblDescription.text = "Sit or stand upright and tap below to set your upright posture. You can also double-press the device button."
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        objLive = Live()
        objLive?.appMode = 1
        objLive?.addDelegate(self as LiveDelegate)
        breathingGraphView.objLive = objLive
        
        setBreathSensitivity(val: 2)
        setPostureSensitivity(val: 2)
        
        displayPostureAnimation(1)
        
        btnNext.isHidden = true
        
        startLive()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopLive()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DevicesViewController {
            stopLive()
        }
    }
    
    @IBAction func onUpright(_ sender: Any) {
        objLive?.learnUprightAngleHandler()
    }
    
    @IBAction func onBreathSensitivityChange(_ sender: UIButton) {
        print("clicked \(sender.tag)")
        setBreathSensitivity(val: sender.tag)
    }
    
    @IBAction func onPostureSensitivityChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    @IBAction func onNext(_ sender: Any) {
        
        if isLowerBack {
            let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialWearUpperchestViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialVisualViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func startLive() {
        if !PranaDeviceManager.shared.isConnected {
            let alert = UIAlertController(title: "Prana", message: "No Prana Device is connected. Please Search and connect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        isLive = true
        
        PranaDeviceManager.shared.startGettingLiveData()
    }
    
    func stopLive() {
        isLive = false
        
        PranaDeviceManager.shared.stopGettingLiveData()
    }
    
    func setBreathSensitivity(val: Int) {
        
        btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnBreathSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnBreathSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnBreathSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        btnPostureSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnPostureSensitivityRadio1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnPostureSensitivityRadio2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnPostureSensitivityRadio3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setPostureResponsiveness(val: val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        var frame = whichFrame
//        if frame > 30 {
//            frame = 30
//        }
//
//        if frame < 1 {
//            frame = 1
//        }
        
        if isLowerBack {
            imgPostureAnimation.image = UIImage(named: "sit (\(frame))")
        }
        else {
            imgPostureAnimation.image = UIImage(named: "stand (\(frame))")
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

extension LiveFeedViewController: LiveDelegate {
    func liveDebug(para1: String, para2: String, para3: String, para4: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            //            self.displayDebugStats(ln1: para1, ln2: para2, ln3: para3, ln4: para4)
        }
    }
    
    func liveNewBreathingCalculated() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            //            self.postureIndicatorView.displayPostureIndicator(x: self.objLive?.xPos ?? 0)
        }
    }
    
    func liveNewPostureCalculated() {
        DispatchQueue.main.async {
            self.displayPostureAnimation(self.objLive?.whichPostureFrame ?? 1)
        }
    }
    
    func liveNewRespRateCaclculated() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
        }
    }
    
    func liveDidUprightSet() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.btnNext.isHidden = false
        }
    }
}
