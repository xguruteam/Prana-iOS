//
//  PassiveTrackingViewController.swift
//  Prana
//
//  Created by Guru on 6/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PassiveTrackingViewController: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var batteryView: BatteryStateView!
    @IBOutlet weak var lblTimeElapsed: UILabel!
    @IBOutlet weak var liveGraph: LiveGraph!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var lblStatus4: UILabel!
    @IBOutlet weak var lblStatus5: UILabel!
    @IBOutlet weak var lblStatus6: UILabel!
    
    @IBOutlet weak var btnBreathSense1: UIButton!
    @IBOutlet weak var btnBreathSense2: UIButton!
    @IBOutlet weak var btnBreathSense3: UIButton!
    
    @IBOutlet weak var imgPosture: UIImageView!
    @IBOutlet weak var lblStatus7: UILabel!
    @IBOutlet weak var lblStatus8: UILabel!

    @IBOutlet weak var switchSlouching: UISwitch!
    @IBOutlet weak var ddBuzzIn: PranaDropDown!
    @IBOutlet weak var btWearing1: PranaButton!
    @IBOutlet weak var btWearing2: PranaButton!
    
    @IBOutlet weak var btnPostureSense1: UIButton!
    @IBOutlet weak var btnPostureSense2: UIButton!
    @IBOutlet weak var btnPostureSense3: UIButton!
    
    @IBOutlet weak var breathSenseGroup: UIView!
    @IBOutlet weak var postureSenseGroup: UIView!
    
    var objLive: Live?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        
        objLive = Live()
        objLive?.appMode = 1
        objLive?.addDelegate(self)
        liveGraph.objLive = objLive
        
        setBreathSensitivity(val: 2)
        setPostureSensitivity(val: 2)

        displayPostureAnimation(1)


    }
    
    func initView() {
        
        let border1 = CALayer()
        border1.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border1.frame = CGRect(x: 0.0, y: breathSenseGroup.frame.height + 4.0, width: breathSenseGroup.frame.width, height: 1.0)
        
        breathSenseGroup.layer.addSublayer(border1)
        
        let border2 = CALayer()
        border2.backgroundColor = UIColor(red: 224.0/256.0, green: 224.0/256.0, blue: 224.0/256.0, alpha: 1).cgColor
        border2.frame = CGRect(x: 0.0, y: postureSenseGroup.frame.height + 4.0, width: postureSenseGroup.frame.width, height: 1.0)
        
        postureSenseGroup.layer.addSublayer(border2)
        
        switchSlouching.tintColor = UIColor(hexString: "#2bb7b8")
        switchSlouching.onTintColor = UIColor(hexString: "#2bb7b8")
    }
    

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        var text: [AttributedTextBlock] = [
            .list("Tracking allows you to track both your breathing and posture in the background, not requiring your attention. Tracking is recommended only while sitting or standing, not walking or running. You can track for as long as you wish."),
            .list("Tracking is useful to learn how your breathing and posture are working unconsciously (what your average respiration rate is and how often you are slouching). A higher non-active respiration rate can be linked to more stressed situations."),
            .list("You can opt to get buzzes when slouching in this mode. You can set the buzz times to be less frequent/strict than in training mode."),
            .list("If you are discovering stressed breathing or poor posture during tracking, our suggestion in both cases is just to hop into training mode and do a training session, and/or adjust your daily training minute goals."),
        ]
        
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
    
    @IBAction func onBreathResponsivenessChange(_ sender: UIButton) {
        setBreathSensitivity(val: sender.tag)
    }
    
    @IBAction func onPostureSenseChange(_ sender: UIButton) {
        setPostureSensitivity(val: sender.tag)
    }
    
    @IBAction func onUpright(_ sender: Any) {
    }
    
    @IBAction func onStartStop(_ sender: Any) {
    }
    
    @IBAction func onEnableSlouchBuzzChange(_ sender: Any) {
    }
    
    func setBreathSensitivity(val: Int) {
        btnBreathSense1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSense2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnBreathSense3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnBreathSense1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnBreathSense2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnBreathSense3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        btnPostureSense1.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSense2.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        btnPostureSense3.setBackgroundImage(UIImage(named: "radio-blue-normal"), for: .normal)
        
        switch val {
        case 1:
            btnPostureSense1.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 2:
            btnPostureSense2.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        case 3:
            btnPostureSense3.setBackgroundImage(UIImage(named: "radio-blue-selected"), for: .normal)
        default:
            return
        }
        
        objLive?.setPostureResponsiveness(val: val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
//        var frame = whichFrame
//        if sessionWearing == 0 {
//            imgPosture.image = UIImage(named: "sit (\(frame))")
//        }
//        else {
//            imgPosture.image = UIImage(named: "stand (\(frame))")
//        }
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

extension PassiveTrackingViewController: LiveDelegate {
    func liveProcess(sensorData: [Double]) {
        DispatchQueue.main.async {
            self.batteryView.progress = CGFloat(sensorData[6]) / 100.0
        }
    }
    
    func liveDebug(para1: String, para2: String, para3: String, para4: String) {
        
    }
    
    func liveNewBreathingCalculated() {
        
    }
    
    func liveNewPostureCalculated() {
        DispatchQueue.main.async {
            self.displayPostureAnimation(self.objLive?.whichPostureFrame ?? 1)
        }
    }
    
    func liveNewRespRateCaclculated() {
        
    }
    
    func liveDidUprightSet() {
//        uprightHasBeenSetHandler()
    }
    
}
