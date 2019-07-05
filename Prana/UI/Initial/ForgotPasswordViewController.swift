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
import MKProgress

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var lbl_error_email: UILabel!
    @IBOutlet weak var lbl_copyright: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        initView()
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
        lbl_error_email.isHidden = true
        
        lbl_copyright.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @IBAction func onBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        var alertController:UIAlertController!
        
        if (!Utils.isValidEmail(str:tf_email.text!)) {
            alertController = UIAlertController(title: "Input Error", message: "Invaild Email", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: false, completion: nil)
            
            return
        }
        
        submitRequest()
    }
    
    func submitRequest() {
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Loading..."
        MKProgress.show()
        
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
//                MBProgressHUD.hide(for: self.view, animated: true)
                MKProgress.hide()
        }
    }
}
