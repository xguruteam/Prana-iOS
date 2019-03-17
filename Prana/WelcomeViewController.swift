//
//  WelcomeViewController.swift
//  Prana
//
//  Created by Luccas on 2019/2/28.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

extension Notification.Name {
    static let connectViewControllerDidNext = Notification.Name("connectViewControllerDidNext")
}

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldLogin()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectViewControllerNext), name: .connectViewControllerDidNext, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    @objc func onConnectViewControllerNext() {
        self.dismiss(animated: false) {
            let firstVC = Utils.getStoryboardWithIdentifier(identifier: "TutorialStartViewController")
            //        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "FirstViewController")
            let navVC = UINavigationController(rootViewController: firstVC)
            self.present(navVC, animated: true, completion: nil)

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

    
    @IBAction func onSignupButtonClick(_ sender: UIButton) {
        
    }
    
    
    @IBAction func onLoginButtonClick(_ sender: UIButton) {
        
    }
    
    func shouldLogin() {
        let autoLogin = UserDefaults.standard.bool(forKey: KEY_REMEMBERME)
        if (!autoLogin) {
            return
        }
        
        let expireDateStr = UserDefaults.standard.string(forKey: KEY_EXPIREAT)
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let expireDate = formatter.date(from: expireDateStr!)
        let curDate2h = formatter.date(from: formatter.string(from: Calendar.current.date(byAdding: .hour, value: +2, to: Date())!))
        if (expireDate?.compare(curDate2h!) == .orderedAscending) {
            return
        }
        
        var isValidToken = false
        let accessToken = UserDefaults.standard.string(forKey: KEY_TOKEN)
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken!)"
        ]
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        
        APIClient.sessionManager.request(APIClient.BaseURL + "profile", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    isValidToken = true
                    break
                case .failure:
                    isValidToken = false
                    break
                }
                MBProgressHUD.hide(for: self.view, animated: true)
                if (isValidToken) {
                    self.navigationController?.popToRootViewController(animated: false)
                    // let firstVC = self.getStoryboardWithIdentifier(identifier: "FirstViewController")
                    let firstVC = self.getStoryboardWithIdentifier(identifier: "ChargingGuideViewController")
                    let navVC = UINavigationController(rootViewController: firstVC)
                    self.present(navVC, animated: true, completion: nil)
                }
        }
    }
    
    func getStoryboardWithIdentifier(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller;
    }
}
