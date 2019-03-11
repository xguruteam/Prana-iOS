//
//  SignupViewController.swift
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

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tf_firstname: UITextField!
    @IBOutlet weak var tf_lastname: UITextField!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var tf_confirmpassword: UITextField!
    @IBOutlet weak var tf_birthdate: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_gendermale: UIButton!
    @IBOutlet weak var btn_genderfemale: UIButton!
    
    var strGender: String!
    
    var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        
        tf_birthdate.delegate = self
        
        strGender = "male"
        btn_gendermale.layer.cornerRadius = 12
        btn_gendermale.clipsToBounds = true
        btn_genderfemale.layer.cornerRadius = 12
        btn_genderfemale.clipsToBounds = true
        genderChanged()
        updateUI()
    }
    
    @IBAction func onback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateUI() {
    }

    @IBAction func onSubmitClick(_ sender: Any) {
        
        var alertController:UIAlertController!
        
        if tf_firstname.text! == "" {
            alertController = UIAlertController(title: "Input Error", message: "Please input your first name", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if tf_lastname.text! == "" {
            alertController = UIAlertController(title: "Input Error", message: "Please input last first name", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if !Utils.isValidEmail(str:tf_email.text!) {
            alertController = UIAlertController(title: "Input Error", message: "Invalid Email", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if !Utils.isValidPassword(str:tf_password.text!) {
            alertController = UIAlertController(title: "Input Error", message: "Password must be 4 - 20 chars", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        if !Utils.isValidPassword(str:tf_confirmpassword.text!) {
            alertController = UIAlertController(title: "Input Error", message: "Password must be 4 - 20 chars", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: false, completion: nil)
            return
        }
        
        signup()
    }
    
    func signup() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        
        let param: Parameters = [
            "first_name": tf_firstname.text!,
            "last_name": tf_lastname.text!,
            "email": tf_email.text!,
            "password": tf_password.text!,
            "birth_date": tf_birthdate.text!,
            "gender": strGender
        ]
        APIClient.sessionManager.request(APIClient.BaseURL + "register", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    let alertController = UIAlertController(title: "Success", message:
                        "Sign up success", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: false, completion: nil)
                    break
                case .failure:
                    if response.response == nil {
                        let alertController = UIAlertController(title: "Error", message:
                            "Network error", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                        break
                    } else if response.response!.statusCode == 500 {
                        let alertController = UIAlertController(title: "Error", message:
                            "Server Error!", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                        break
                    } else if response.response!.statusCode == 422 {
                        let alertController = UIAlertController(title: "Error", message:
                            "Invalid Data", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                        break
                    } else {
                        let alertController = UIAlertController(title: "Error", message:
                            "error", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: false, completion: nil)
                        break
                    }
                }
                MBProgressHUD.hide(for: self.view, animated: true)
            }
    }
    
    @IBAction func onTouchScreen(_ sender: Any) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == tf_birthdate){
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePicker.Mode.date
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction func onGenderMaleClick(_ sender: Any) {
        strGender = "male"
        genderChanged()
    }
    
    @IBAction func onGenderFemaleClick(_ sender: Any) {
        strGender = "female"
        genderChanged()
    }
    
    func genderChanged() {
        if strGender == "male" {
            btn_gendermale.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
            btn_gendermale.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1).cgColor
            
            btn_genderfemale.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
            btn_genderfemale.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        } else {
            btn_genderfemale.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1)
            btn_genderfemale.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1).cgColor
            
            btn_gendermale.backgroundColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 0.1)
            btn_gendermale.layer.borderColor = UIColor(red: 32/255, green: 203/255, blue: 245/255, alpha: 1).cgColor
        }
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let formatter = DateFormatter()
        
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/YYYY"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        
        tf_birthdate.text = formatter.string(from: sender.date)
        
    }
}
