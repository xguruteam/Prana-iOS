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
import MKProgress

class LoginViewController: SuperViewController {

    @IBOutlet weak var img_logo: UIImageView!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var lbl_copyright: UILabel!
    @IBOutlet weak var lbl_error_email: UILabel!
    @IBOutlet weak var lbl_error_password: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true

        initView()
        tf_email.spellCheckingType = .no
    }

    func initView() {
        let background = UIImage(named: "app-background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.insertSubview(imageView, at: 0)
        view.sendSubviewToBack(imageView)
        
        tf_email.borderStyle = .none
        tf_email.borderWidth = 0
        tf_password.borderStyle = .none
        
        lbl_error_email.isHidden = true
        lbl_error_password.isHidden = true
        
        lbl_copyright.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Loading..."
        MKProgress.show()
        
        let remember_me = true
        let param: Parameters = [
            "email": tf_email.text!,
            "password": tf_password.text!,
            "remember_me": remember_me,
        ]
        APIClient.sessionManager.request(APIClient.BaseURL + "login", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                MKProgress.hide()
                switch response.result {
                case .success:
                    if let data = response.value as? [String: Any] {
                        let token = data["access_token"] as! String
                        let expires_at = data["expires_at"] as! String
                        UserDefaults.standard.set(token, forKey: KEY_TOKEN)
                        UserDefaults.standard.set(expires_at, forKey: KEY_EXPIREAT)
                        UserDefaults.standard.set(remember_me, forKey: KEY_REMEMBERME)
                        UserDefaults.standard.synchronize()
                        self.dataController.currentUser = User(data: data)
                        self.dataController.saveUserData()
                        self.dataController.clearData()
                        // let firstVC = Utils.getStoryboardWithIdentifier(identifier: "FirstViewController")
                        self.navigationController?.popToRootViewController(animated: false)
                        NotificationCenter.default.post(name: .didLogIn, object: nil)
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
//                MBProgressHUD.hide(for: self.view, animated: true)
                
        }
    }
    
    @IBAction func onBlinkClick(_ sender: UIButton) {
        if tf_password.isSecureTextEntry {
            tf_password.isSecureTextEntry = false
        } else {
            tf_password.isSecureTextEntry = true
        }
    }
}
