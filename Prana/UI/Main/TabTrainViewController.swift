//
//  TabTrainViewController.swift
//  Prana
//
//  Created by Dev on 4/12/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth

class TabTrainViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var breathCircle: PranaCircleProgressView!
    @IBOutlet weak var lblMindfulBreathTime: UILabel!
    @IBOutlet weak var lblBreathResult: UILabel!
    @IBOutlet weak var lblBreathGoal: UILabel!
    
    @IBOutlet weak var postureCircle: PranaCircleProgressView!
    @IBOutlet weak var lblUprightPostureTime: UILabel!
    @IBOutlet weak var lblPostureResult: UILabel!
    @IBOutlet weak var lblPostureGoal: UILabel!
    
    @IBOutlet weak var btnTraining: UIButton!
    @IBOutlet weak var btnTracking: UIButton!
    @IBOutlet weak var btnLiveGraph: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var bluetoothView: BluetoothStateView!
    
    var dataController: DataController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            dataController = appDelegate.dataController
        }
        
        lblTitle.text = "Today's Achievements"
        
        if let titleFont = UIFont(name: "Quicksand-Bold", size: 24.0)  {
            let shadow : NSShadow = NSShadow()
            shadow.shadowOffset = CGSize(width: 0, height: 2)
            shadow.shadowColor = UIColor(hexString: "#910c5274")
            shadow.shadowBlurRadius = 4
            
            let attributes = [
                NSAttributedString.Key.font : titleFont,
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.strokeWidth : -1.0,
                .strokeColor : UIColor.black,
                NSAttributedString.Key.shadow : shadow] as [NSAttributedString.Key : Any]
            
            var title = NSAttributedString(string: "Today's Achievements", attributes: attributes) //1
            
            lblTitle.attributedText = title //3
        }
//        getTrainSummary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        PranaDeviceManager.shared.addDelegate(self)
        bluetoothView.isEnabled = PranaDeviceManager.shared.isConnected
        
        let dayNumber = dataController?.currentDay ?? 0
        if let currentProgram = dataController?.currentProgram, dayNumber > 14 {
            if currentProgram.type == .fourteen {
                let alert = UIAlertController(style: .alert, title: "14 day Program", message: "Congratulation! You have completed the 14 day training program.")
                alert.addAction(title: "Ok", style: .cancel)
                alert.show()
                currentProgram.endedAt = Date()
                currentProgram.status = "completed"
                dataController?.endProgram(currentProgram)
            }
        }
        
        if let currentProgram = dataController?.currentProgram {
            lblMindfulBreathTime.text = "0"
            lblBreathResult.text = "0% Mindful"
            lblUprightPostureTime.text = "0"
            lblPostureResult.text = "0% Upright"
            if currentProgram.type == .fourteen {
                let dayNumber = dataController?.currentDay ?? 0
                let (breathingGoal, postureGoal, wearing) = fourteenGoals[dayNumber]
                lblBreathGoal.text = "\(breathingGoal) mins"
                lblPostureGoal.text = "\(postureGoal) mins"
            }
            else {
                lblBreathGoal.text = "\(dataController?.breathingGoals ?? 0) mins"
                lblPostureGoal.text = "\(dataController?.postureGoals ?? 0) mins"
            }
            
            calculateSummary()
        }
        else {
            lblMindfulBreathTime.text = "0"
            lblBreathResult.text = " "
            lblBreathGoal.text = "Set up your Training"
            lblUprightPostureTime.text = "0"
            lblPostureResult.text = " "
            lblPostureGoal.text = "Set up your Training"
            
            breathCircle.progress = 0.0
            postureCircle.progress = 0.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PranaDeviceManager.shared.removeDelegate(self)
    }
    
    func calculateSummary() {
        if let sessions = dataController?.fetchSessions(), let _ = sessions.first {
            let (breathingElapsed, postureElapsed, mindfulDuration, uprightDuration) = sessions.reduce((0, 0, 0, 0)) { (acc, session) -> (Int, Int, Int, Int) in
                var result = acc
                
                let calendar = Calendar.current
                if calendar.isDateInToday(session.startedAt) == false {
                    return result
                }
                if session.kind == 1 {
                    result.0 += session.duration
                }
                else if session.kind == 2 {
                    result.1 += session.duration
                }
                else {
                    result.0 += session.duration
                    result.1 += session.duration
                }
                result.2 += session.mindful
                result.3 += session.upright
                
                return result
            }
            
            if breathingElapsed > 0 {
                lblBreathResult.text = "\(mindfulDuration * 100 / breathingElapsed)% Mindful"
            }
            else {
                lblBreathResult.text = "0% Mindful"
            }
        
            if postureElapsed > 0 {
                lblPostureResult.text = "\(uprightDuration * 100 / postureElapsed)% Upright"
            }
            else {
                lblPostureResult.text = "0% Upright"
            }
            
            
            lblMindfulBreathTime.text = "\(breathingElapsed / 60)"
            lblUprightPostureTime.text = "\(postureElapsed / 60)"
            
            if let currentProgram = dataController?.currentProgram {
                if currentProgram.type == .fourteen {
                    let dayNumber = dataController?.currentDay ?? 0
                    let (breathingGoal, postureGoal, wearing) = fourteenGoals[dayNumber]
                    breathCircle.progress = CGFloat(breathingElapsed / 60) / CGFloat(breathingGoal)
                    postureCircle.progress = CGFloat(postureElapsed / 60) / CGFloat(postureGoal)
                }
                else {
                    breathCircle.progress = CGFloat(breathingElapsed / 60) / CGFloat(dataController!.breathingGoals)
                    postureCircle.progress = CGFloat(postureElapsed / 60) / CGFloat(dataController!.postureGoals)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.breathCircle.startAnimation()
//                self.postureCircle.startAnimation()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
//                self.breathCircle.startAnimation()
                self.postureCircle.startAnimation()
            })
        }
    }
    
    func initView() {
        self.navigationController?.isNavigationBarHidden = true
        
        let background = UIImage(named: "app-background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        container.insertSubview(imageView, at: 0)
        container.sendSubviewToBack(imageView)
        
        applyButtonGradient(button: btnTraining, colors: [UIColor(red: 67.0/256.0, green: 227.0/256.0, blue: 218.0/256.0, alpha: 1.0), UIColor(red: 26.0/256.0, green: 150.0/256.0, blue: 153.0/256.0, alpha: 1.0)], locations: [0.0, 1.0])
        
        applyButtonGradient(button: btnTracking, colors: [UIColor(red: 161.0/256.0, green: 218.0/256.0, blue: 61.0/256.0, alpha: 1.0), UIColor(red: 94.0/256.0, green: 184.0/256.0, blue: 57.0/256.0, alpha: 1.0)], locations: [0.0, 1.0])
        
        //        btnLiveGraph.setTitle("Live Graph", for: .normal)
        //        btnLiveGraph.titleLabel?.textAlignment = .center
        //        btnLiveGraph.titleLabel?.lineBreakMode = .byWordWrapping
        //        btnLiveGraph.titleLabel?.numberOfLines = 2
        applyButtonGradient(button: btnLiveGraph, colors: [UIColor(red: 106.0/256.0, green: 215.0/256.0, blue: 141.0/256.0, alpha: 1.0), UIColor(red: 86.0/256.0, green: 176.0/256.0, blue: 134.0/256.0, alpha: 1.0)], locations: [0.0, 1.0])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func onTrainClick(_ sender: UIButton) {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ProgramsViewController")
//        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(firstVC, animated: true, completion: nil)
    }
    
    @IBAction func onLiveGraphClick(_ sender: UIButton) {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "LiveGraphViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func applyButtonGradient(button: UIButton, colors: [UIColor], locations: [NSNumber]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = button.bounds
        gradient.colors = colors.map { $0.withAlphaComponent(1.0).cgColor }
        gradient.locations = locations
        
        button.layer.addSublayer(gradient)
    }
    
}

extension TabTrainViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidStartScan() {
        
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        DispatchQueue.main.async {
            self.bluetoothView.isEnabled = true
        }
    }
    
    func PranaDeviceManagerFailConnect() {
        DispatchQueue.main.async {
            self.bluetoothView.isEnabled = false
        }
    }
    
    func PranaDeviceManagerDidOpenChannel() {
        
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
        
    }
    
    
}
