//
//  LoginViewController.swift
//  Prana
//
//  Created by Luccas on 2019/2/28.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Crashlytics
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var swi_keeplogin: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false

        updateUI()
    }

    func updateUI() {
        
    }

    @IBAction func onBackClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onLoginClick(_ sender: Any) {
        
//        let x = true
//        if x {
//            let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ChargingGuideViewController")
//            let navVC = UINavigationController(rootViewController: firstVC)
//            self.present(navVC, animated: true, completion: nil)
//            return
//        }
        
        
        var alertController:UIAlertController!
        
        if (!Utils.isValidEmail(str:tf_email.text!)) {
            alertController = UIAlertController(title: "Input Error", message: "Invalid Email", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if (!Utils.isValidPassword(str:tf_password.text!)) {
            alertController = UIAlertController(title: "Input Error", message: "Password must be 4 - 20 chars", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        login()
    }
    
    func login() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        
        let remember_me = swi_keeplogin.isOn
        let param: Parameters = [
            "email": tf_email.text!,
            "password": tf_password.text!,
            "remember_me": remember_me,
        ]
        APIClient.sessionManager.request(APIClient.BaseURL + "login", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    if let data = response.value as? [String: Any] {
                        let token = data["access_token"] as! String
                        let expires_at = data["expires_at"] as! String
                        UserDefaults.standard.set(token, forKey: KEY_TOKEN)
                        UserDefaults.standard.set(expires_at, forKey: KEY_EXPIREAT)
                        UserDefaults.standard.set(remember_me, forKey: KEY_REMEMBERME)
                        UserDefaults.standard.synchronize()
                        // let firstVC = Utils.getStoryboardWithIdentifier(identifier: "FirstViewController")
                        self.navigationController?.popToRootViewController(animated: false)
                        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ChargingGuideViewController")
                        let navVC = UINavigationController(rootViewController: firstVC)
                        self.present(navVC, animated: true, completion: nil)
                    }
                    
                    break
                case .failure:
                    if response.response == nil {
                        let alertController = UIAlertController(title: "Network Error", message:
                            "Unable to connect server", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    } else if response.response!.statusCode == 401 {
                        let alertController = UIAlertController(title: "Error", message:
                            "Incorrect email or password", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Error", message:
                            "Login failed", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    }
                    break
                }
                MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
}
