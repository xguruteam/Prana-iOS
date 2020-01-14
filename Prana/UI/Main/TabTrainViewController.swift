//
//  TabTrainViewController.swift
//  Prana
//
//  Created by Dev on 4/12/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth
import Toaster
import Crashlytics
import Fabric

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
    
    var requestCode: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            dataController = appDelegate.dataController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PranaDeviceManager.shared.addDelegate(self)
        bluetoothView.isEnabled = PranaDeviceManager.shared.isConnected
        
        let dayNumber = dataController?.numberOfDaysPast ?? 0
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
                let dayNumber = dataController?.numberOfDaysPast ?? 0
                let (breathingGoal, postureGoal, _) = fourteenGoals[dayNumber]
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
    
    func initView() {
        self.navigationController?.isNavigationBarHidden = true
        
        //Init background image
        let background = UIImage(named: "app-background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        container.insertSubview(imageView, at: 0)
        container.sendSubviewToBack(imageView)

        btnTraining.applyButtonGradient(colors: [#colorLiteral(red: 0.2823529412, green: 0.8705882353, blue: 0.8352941176, alpha: 1), #colorLiteral(red: 0.1137254902, green: 0.6117647059, blue: 0.6196078431, alpha: 1)], points: [0.0, 1.0])
        btnTracking.applyButtonGradient(colors: [#colorLiteral(red: 0.6117647059, green: 0.8470588235, blue: 0.2352941176, alpha: 1), #colorLiteral(red: 0.3803921569, green: 0.7333333333, blue: 0.2156862745, alpha: 1)], points: [0.0, 1.0])
        btnLiveGraph.applyButtonGradient(colors: [#colorLiteral(red: 0.4156862745, green: 0.8352941176, blue: 0.5529411765, alpha: 1), #colorLiteral(red: 0.2509803922, green: 0.662745098, blue: 0.462745098, alpha: 1)], points: [0.0, 1.0])

        btnLiveGraph.titleLabel?.numberOfLines = 0
        btnLiveGraph.titleLabel?.lineBreakMode = .byWordWrapping
        btnLiveGraph.setTitle("Live\nGraph", for: .normal)
        btnLiveGraph.titleLabel?.textAlignment = .center
        btnLiveGraph.sizeToFit()
        
        lblTitle.text = "Today's Achievements"
        
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 2)
        shadow.shadowColor = UIColor(hexString: "#910c5274")
        shadow.shadowBlurRadius = 4
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.bold(ofSize: 24),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : -1.0,
            .strokeColor : UIColor.black,
            NSAttributedString.Key.shadow : shadow] as [NSAttributedString.Key : Any]
        
        let title = NSAttributedString(string: "Today's Achievements", attributes: attributes) //1
        
        lblTitle.attributedText = title //3
    }
    
    func calculateSummary() {
        print("-----> summary begin, today: \(Date())")
        print("-----> summary begin, today: \(Calendar.current.timeZone)")
        if let sessions = dataController?.fetchDailySessions(date: Date()).filter({ (object) -> Bool in
            return object is TrainingSession
        }) as? [TrainingSession], let _ = sessions.first {
            let (breathCount, postureElapsed, mindfuls, uprightDuration, breathingElapsed) = sessions.reduce((0, 0, 0, 0, 0)) { (acc, session) -> (Int, Int, Int, Int, Int) in
                print("session date: \(session.startedAt), duration: \(session.duration)")
                var result = acc
                
                let calendar = Calendar.current
                if calendar.isDateInToday(session.startedAt) == false {
                    return result
                }
                if session.kind == 0 || session.kind == 1 {
                    let (breaths, _, mindfuls, _)  = session.sumBreaths()
                    result.0 += breaths
                    result.2 += mindfuls
                    result.4 += session.duration
                }
                
                if session.kind == 0 || session.kind == 2 {
                    result.1 += session.duration

                    let slouchDuration = session.sumSlouches().0
                    let uprightDuration = session.duration - slouchDuration
                    if uprightDuration > 0 {
                        result.3 += uprightDuration
                    }
                }
                
                return result
            }
            
            if breathCount > 0 {
                lblBreathResult.text = "\(mindfuls * 100 / breathCount)% Mindful"
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
                    let dayNumber = dataController?.numberOfDaysPast ?? 0
                    let (breathingGoal, postureGoal, _) = fourteenGoals[dayNumber]
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
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.postureCircle.startAnimation()
            })
        }
        print("<------ summary end")
    }
    

    @IBAction func onTrainClick(_ sender: UIButton) {
        let firstVC = Utils.getStoryboardWithIdentifier(name: "BreathingPosture", identifier: "ProgramsViewController")
        self.present(firstVC, animated: true, completion: nil)
    }
    
    @IBAction func onTracking(_ sender: Any) {
        if PranaDeviceManager.shared.isConnected {
            gotoTracking()
            return
        }
        
        requestCode = 0        
        gotoConnectViewController()
    }
    
    func gotoTracking() {
        let vc = Utils.getStoryboardWithIdentifier(name: "BreathingPosture", identifier: "PassiveTrackingViewController") as! PassiveTrackingViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onLiveGraphClick(_ sender: UIButton) {
        if PranaDeviceManager.shared.isConnected {
            gotoLiveGraph()
            return
        }
        
        requestCode = 1
        gotoConnectViewController()
    }
    
    func gotoLiveGraph() {
        let firstVC = Utils.getStoryboardWithIdentifier(name: "BreathingPosture", identifier: "LiveGraphViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc func onConnectViewControllerNextToSession() {
        if requestCode == 0 {
            gotoTracking()
        }
        else {
            gotoLiveGraph()
        }
    }
    
    func gotoConnectViewController() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ConnectViewController") as! ConnectViewController
        firstVC.isTutorial = false
        
        if requestCode == 0 {
            firstVC.completionHandler = { [unowned self] in
                self.gotoTracking()
            }
        }
        else {
            firstVC.completionHandler = { [unowned self] in
                self.gotoLiveGraph()
            }
        }
        
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
}

extension TabTrainViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        DispatchQueue.main.async {
            self.bluetoothView.isEnabled = true
        }
    }
    
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async {
            self.bluetoothView.isEnabled = false
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont.medium(ofSize: 14)
            toast.show()
        }
    }
    
}
