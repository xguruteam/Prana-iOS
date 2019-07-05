//
//  FirstViewController.swift
//  Prana
//
//  Created by Luccas on 3/1/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController {

    var currentSession: TrainingSession?
    var timer: Timer?
    
    var sessionElapsed: Int = 0
    var sessionInterval: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(onLandscapeViewControllerDismiss), name: .landscapeViewControllerDidDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: .deviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    @objc func onLandscapeViewControllerDismiss() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    @objc func onDeviceOrientationChange() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func onLogoutClicked(_ sender: Any) {
//        UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
//        UserDefaults.standard.removeObject(forKey: KEY_EXPIREAT)
//        UserDefaults.standard.removeObject(forKey: KEY_REMEMBERME)
//        UserDefaults.standard.synchronize()
//        
//        if PranaDeviceManager.shared.isConnected {
//            PranaDeviceManager.shared.stopGettingLiveData()
//            PranaDeviceManager.shared.disconnect()
//            PranaDeviceManager.shared.delegate = nil
//        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHistoryClicked(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
        UserDefaults.standard.removeObject(forKey: KEY_EXPIREAT)
        UserDefaults.standard.removeObject(forKey: KEY_REMEMBERME)
        UserDefaults.standard.synchronize()

        if PranaDeviceManager.shared.isConnected {
            PranaDeviceManager.shared.stopGettingLiveData()
            PranaDeviceManager.shared.disconnect()
            PranaDeviceManager.shared.delegate = nil
        }

        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBuzzerTrainingClicked(_ sender: UIButton) {
        let vc = Utils.getStoryboardWithIdentifier(identifier: "BuzzerTrainingViewController")
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func onVisualTrainingClicked(_ sender: UIButton) {
        let vc = Utils.getStoryboardWithIdentifier(identifier:"VisualTrainingViewController")
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func onGenTrainingClicked(_ sender: Any) {
        
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Press the button to end session"
//
//        hud.button.setTitle("End Session", for: .normal)
//        hud.button.addTarget(self, action: #selector(onEnd(_:)), for: .touchUpInside)
//
//        if let _ = timer {
//            self.timer?.invalidate()
//        }
//
//        currentSession = Session()
//        sessionInterval = Float.random(in: 0.5 ... 2)
//        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: sessionInterval) ?? 1.0, repeats: true, block: { (_) in
//            let now = Date()
//            let elapsed = now.timeIntervalSince(self.currentSession!.startTime)
//
//            let isSlouch = Bool.random()
//            if isSlouch == true {
//                let slouch = Slouch(Int(elapsed))
//                self.currentSession?.slouches.append(slouch)
//            }
//
//            let breathing = Breathing(Int(elapsed))
//            let isMindful = Bool.random()
//            if isMindful == true {
//                breathing.isMindful = isMindful
//            }
//            self.currentSession?.breathings.append(breathing)
//
//            print("breathing \(elapsed)s")
//        })
        
        
        
    }
    
    @IBAction func onGenTrackingClicked(_ sender: Any) {
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Press the button to end session"
//        
//        hud.button.setTitle("End Session", for: .normal)
//        hud.button.addTarget(self, action: #selector(onEnd(_:)), for: .touchUpInside)
        
        if let _ = timer {
            self.timer?.invalidate()
        }
        
//        currentSession = Session()
//        currentSession?.sessionType = 1
//        sessionInterval = Float.random(in: 0.5 ... 2)
    }
    
    @IBAction func onEnd(_ sender: Any) {
//        if let _ = timer {
//            self.timer?.invalidate()
//            self.timer = nil
//        }
//
//        guard let session = self.currentSession else {
//            return
//        }
//
//        let now = Date()
//        let elapsed = now.timeIntervalSince(self.currentSession!.startTime)
//
//        session.elasped = Int(elapsed)
//        session.uprightScore = Float.random(in: 0 ... 100) // Float(session.slouches.count) / Float(session.breathings.count) * 100.0
//        session.position = Int.random(in: 0 ... 1)
//
////        let mindfulCount = session.breathings.reduce(0) { (count, breathing) -> Int in
////            if breathing.isMindful == true {
////                return count + 1
////            }
////            return count
////        }
//
////        session.mindfulScore = Float(mindfulCount) / Float(session.breathings.count) * 100.0
//
//        session.mindfulScore = Float.random(in: 0 ... 100)
//
//        session.pattern = 0
//
//        session.avgRR = 60.0 / self.sessionInterval
//
//        print(session.getDictionary())
//
//        postSession()
//
//        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func postSession() {
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Loading..."
//        
//        let param: Parameters = self.currentSession!.getDictionary()
//        
//        let userdefaults = UserDefaults.standard
//        let token = userdefaults.string(forKey: KEY_TOKEN)
//        
//        
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer \(token!)"
//        ]
//        
//        APIClient.sessionManager.request(APIClient.BaseURL + "trainsessions", method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
//            .validate(statusCode: 200..<300)
//            .responseJSON {(response) in
//                switch response.result {
//                case .success:
//                    let alertController = UIAlertController(title: "Success", message:
//                        "Upload session success", preferredStyle: UIAlertController.Style.alert)
//                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
//                    self.present(alertController, animated: false, completion: nil)
//                    break
//                case .failure:
//                    let alertController = UIAlertController(title: "Error", message:
//                        "Upload session failed", preferredStyle: UIAlertController.Style.alert)
//                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
//                    self.present(alertController, animated: false, completion: nil)
//                    break
//                }
//                MBProgressHUD.hide(for: self.view, animated: true)
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
