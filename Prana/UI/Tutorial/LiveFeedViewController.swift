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
    
    @IBOutlet weak var lblHead: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var liveGraphContraint: NSLayoutConstraint!    
    @IBOutlet weak var imageHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var btnHelp: UIButton!
    
    var isLive = false
    var objLive: Live?
    var isLowerBack = true
    

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        self.navigationController?.isNavigationBarHidden = true
        
        if isLowerBack {
            lblHead.text = "Wearing the belt around your waist tracks and encourages diaphragmatic breathing. Now try breathing more abdominally, so that your belly rises as you inhale, and falls as you exhale. Adjust the belt position and tightness if needed."
            lblDescription.text = "Sit upright and tap below to set your upright posture baseline for your lower back. You can also press the device button to set your posture. Now try varying your posture to see how the animated figure is tracking."
        }
        else {
            lblHead.text = "Now breathe normally. You should see your breath on the graph rising as you inhale, and falling as you exhale. Adjust the belt position and tightness if needed. Tap help for more details."
            lblDescription.text = "Sit or stand upright and tap below to set your upright posture baseline for your upper back. You can also press the device button to set your posture. Now try varying your posture to see how the animated figure is tracking."
        }
        
        adjustContraints()
        
        breathRadioGroup.delegate = self
        postureRadioGroup.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startLive()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        btnUpright.applyButtonGradient(colors: [#colorLiteral(red: 0.6, green: 0.8392156863, blue: 0.2392156863, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.7411764706, blue: 0.2274509804, alpha: 1)], points: [0.0, 1.0])
        btnUpright.isHighlighted = false
        btnNext.applyButtonGradient(colors: [#colorLiteral(red: 0.2980392157, green: 0.8470588235, blue: 0.8509803922, alpha: 1), #colorLiteral(red: 0.168627451, green: 0.7176470588, blue: 0.7215686275, alpha: 1)], points: [0.0, 1.0])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopLive()
    }
    
    func adjustContraints() {
        if UIScreen.main.nativeBounds.height >= 1920 { // above 8 plus
            liveGraphContraint.constant = 140
            imageHeightContraint.constant = 110
        }
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        let attributedString: NSMutableAttributedString
        
        var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString = NSMutableAttributedString(string: "", attributes: attributes)
        
        attributes = [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString.append(NSMutableAttributedString(string: "Breath Response ", attributes: attributes))
        
        attributes = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString.append(NSMutableAttributedString(string: """
            – Sets how quickly the graph keeps pace with your breathing.
            The lowest setting makes the signal smoother and slower changing, while the highest setting makes it track even very rapid breaths (with the tradeoff of more noise from body movements).
            For most screens, we automatically choose this setting for you, but you can always manually override it.
            Note that Breath Response is not the same as breath sensitivity.
            For example, if you breathe very lightly, or very deeply, our system is constantly adjusting the sensitivity to track your breathing, so that your typical breath reaches the full graph height.
            Never force your breaths for tracking purposes. Just keep breathing normally and the height of the graph will automatically catch up to track your breathing depth.
            """, attributes: attributes))

        attributes = [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString.append(NSMutableAttributedString(string: "\n\nPosture Sensitivity ", attributes: attributes))
        
        attributes = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString.append(NSMutableAttributedString(string: """
            – Sets how strict the system is to posture changes and slouching.
            The lowest setting requires significant slouching to count as slouching, while the highest setting will respond to minor slouching.
            """, attributes: attributes))
        
        attributes = [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString.append(NSMutableAttributedString(string: "\n\nDevice button ", attributes: attributes))
        
        attributes = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
        attributedString.append(NSMutableAttributedString(string: """
            – While wearing the device and connected, you can press the device button to set your Upright Posture baseline.
            Press and release the button quickly to set.
            """, attributes: attributes))
        
        alert.addTextViewer(text: .attributedText([.raw(attributedString)]))

        alert.addAction(title: "OK", style: .cancel)
        alert.show()    }
    
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
            self.lblDescription.text = "Once breath and posture tracking are satisfactory in this position, tap Next"
//            self.btnUpright.setTitle("SET UPRIGHT ✅", for: .normal)
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
