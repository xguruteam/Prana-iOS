//
//  ResetPasswordViewController.swift
//  Prana
//
//  Created by Dev on 3/11/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Crashlytics
import MBProgressHUD

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var tf_password_confirmation: UITextField!
    
    var token: String = ""
    var email: String = ""
    var password: String = ""
    var password_confirmation = ""
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        token = appDelegate.token
        
        checkPasswordResetToken()
    }
    
    func checkPasswordResetToken() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        
        APIClient.sessionManager.request(APIClient.BaseURL + "password/find/" + token, method: .get, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    if let data = response.value as? [String: Any] {
                        self.email = (data["email"] as? String)!
                    }
                    
                    let alertController = UIAlertController(title: "Success", message:
                        "Valid reset password token.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: false, completion: nil)
                    break
                case .failure:
                    if response.response == nil {
                        let alertController = UIAlertController(title: "Network Error", message:
                            "Unable to connect server", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertController, animated: false, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Error", message:
                            "Invalid reset password token.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertController, animated: false, completion: nil)
                    }
                }
                MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func updateUI()
    {
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        var alertController:UIAlertController!
        
        if (!Utils.isValidPassword(str:tf_password.text!)) {
            alertController = UIAlertController(title: "Input Error", message: "Password must be 4-20 chars.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if (!Utils.isValidPassword(str:tf_password_confirmation.text!)) {
            alertController = UIAlertController(title: "Input Error", message: "Password must be 4-20 chars.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if (tf_password.text! != tf_password_confirmation.text) {
            alertController = UIAlertController(title: "Input Error", message: "Password does not match.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        submitRequest()
    }
    
    func submitRequest() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        
        let param: Parameters = [
            "token": self.token,
            "email": self.email,
            "password": tf_password.text!,
            "password_confirmation": tf_password_confirmation.text!
        ]
        
        APIClient.sessionManager.request(APIClient.BaseURL + "password/reset", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    let alertController = UIAlertController(title: "Success", message:
                        "Password has been successfully updated.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: false, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    break
                case .failure:
                    if response.response == nil {
                        let alertController = UIAlertController(title: "Network Error", message:
                            "Unable to connect server", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    } else {
                        let error = response.result.value as! NSDictionary
                        let alertController = UIAlertController(title: "Error", message:
                            error.object(forKey: "message") as? String, preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    }
                    break
                }
                
                MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
