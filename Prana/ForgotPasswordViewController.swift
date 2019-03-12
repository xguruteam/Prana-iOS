//
//  ForgotPasswordViewController.swift
//  Prana
//
//  Created by Luccas on 3/11/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Crashlytics
import MBProgressHUD

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var tf_email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        updateUI()
    }
    
    func updateUI() {
        
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        var alertController:UIAlertController!
        
        if (!Utils.isValidEmail(str:tf_email.text!)) {
            alertController = UIAlertController(title: "Input Error", message: "Invaild Email", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            return
        }
        
        submitRequest()
    }
    
    func submitRequest() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        
        let param: Parameters = [
            "email": tf_email.text!
        ]
        
        APIClient.sessionManager.request(APIClient.BaseURL + "password/create", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    let alertController = UIAlertController(title: "Success", message:
                        "Password reset has been email sent.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: false, completion: nil)
                    break
                case .failure:
                    if response.response == nil {
                        let alertController = UIAlertController(title: "Network Error", message:
                            "Unable to connect server", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not send password reset email", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                    }
                    break
                }
                MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
