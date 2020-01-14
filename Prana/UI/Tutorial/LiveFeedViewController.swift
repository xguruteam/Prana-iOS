//
//  LiveFeedViewController.swift
//  Prana
//
//  Created by Luccas on 4/16/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Toaster

class LiveFeedViewController: SuperViewController {
    
    @IBOutlet weak var breathingGraphView: LiveGraph!
    @IBOutlet weak var btnUpright: UIButton!
    @IBOutlet weak var imgPostureAnimation: UIImageView!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var breathRadioGroup: RadioGroupButton!
    @IBOutlet weak var postureRadioGroup: RadioGroupButton!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    var isLive = false
    var objLive: Live?
    var isLowerBack = true
    

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
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
        
        startLive()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        btnUpright.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        btnNext.applyButtonGradient(colors: [#colorLiteral(red: 0.2980392157, green: 0.8470588235, blue: 0.8509803922, alpha: 1), #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)], points: [0.0, 1.0])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopLive()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        if !isLowerBack {
            let vc = Utils.getStoryboardWithIdentifier(name:"TutorialTraining", identifier: "TutorialLowerbackViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = Utils.getStoryboardWithIdentifier(name:"TutorialTraining", identifier: "TutorialVisualViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func appMovedToBackground() {
        print("Live Feed: App moved to background!")
        
        onBack(self)
    }
    
    func startLive() {
        if !PranaDeviceManager.shared.isConnected {
            let alert = UIAlertController(title: "Prana", message: "No Prana Device is connected. Please Search and connect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        PranaDeviceManager.shared.addDelegate(self)
        
        objLive = Live()
        objLive?.appMode = 1
        objLive?.addDelegate(self)
        breathingGraphView.objLive = objLive
        
        setBreathSensitivity(val: 2)
        setPostureSensitivity(val: 2)
        
        displayPostureAnimation(1)
        
        btnNext.isHidden = true
        
        isLive = true

        objLive?.startMode()
    }
    
    func stopLive() {
        PranaDeviceManager.shared.removeDelegate(self)
        
        isLive = false
        
        breathingGraphView.objLive = nil
        objLive?.removeDelegate(self)
        
        objLive?.stopMode(reset: dataController.isAutoReset)
        
        objLive = nil
    }
    
    func setBreathSensitivity(val: Int) {
        breathRadioGroup.selectedIndex = val
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    func setPostureSensitivity(val: Int) {
        postureRadioGroup.selectedIndex = val
        objLive?.setPostureResponsiveness(val: val)
    }
    
    func displayPostureAnimation(_ whichFrame: Int) {
        let frame = whichFrame
        if isLowerBack {
            imgPostureAnimation.image = UIImage(named: "sit (\(frame))")
        }
        else {
            imgPostureAnimation.image = UIImage(named: "stand (\(frame))")
        }
    }
}

extension LiveFeedViewController: LiveDelegate {
    
    func liveNew(postureFrame: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.displayPostureAnimation(postureFrame)
        }
    }
    
    func liveUprightHasBeenSet() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.btnNext.isHidden = false
        }
    }
}

extension LiveFeedViewController: RadioGroupButtonDelegate {
    func onSelectedIndex(index: Int, sender: RadioGroupButton) {
        if sender.tag == 1 {
            setBreathSensitivity(val: index)
        } else {
            setPostureSensitivity(val: index)
        }
    }
}

extension LiveFeedViewController: PranaDeviceManagerDelegate
{
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.onBack(self)
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
}
