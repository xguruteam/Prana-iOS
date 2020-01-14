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
import MKProgress


class WelcomeViewController: SuperViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lblCopyright: UILabel!
    @IBOutlet weak var btnSignup: ImageButton!
    @IBOutlet weak var btnLogin: ImageButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        afterLogin()

        // Do any additional setup after loading the view.
        
        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectViewControllerNext), name: .connectViewControllerDidNext, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTutorialDidEnd), name: .tutorialDidEnd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogIn), name: .didLogIn, object: nil)
        
        #if TEST_MODE && !DEBUG
        let alert = UIAlertController(title: "Warning", message: "Test mode is enabled currently. The app may not work properly. Please contact developer. Or you can continue using.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        #endif
        
        shouldLogin()
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
        
        lblCopyright.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    @objc func onConnectViewControllerNext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if appDelegate.dataController.isTutorialPassed {
            gotoMainPage()
            return
        }
        
        let firstVC = Utils.getStoryboardWithIdentifier(name: "TutorialTraining", identifier: "TutorialStartViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc func onTutorialDidEnd() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.dataController.isDevicePaired = true
        appDelegate.dataController.isTutorialPassed = true
        appDelegate.dataController.saveSettings()
        
        gotoMainPage()
    }
    
    @objc func didLogIn() {
        MKProgress.show()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            MKProgress.hide()
            self.afterLogin()
        }
    }
    
    func afterLogin() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if appDelegate.dataController.isTutorialPassed {
            gotoMainPage()
            return
        }
        

        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ChargingGuideViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func gotoMainPage() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "TabViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
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
        if let _ = dataController.currentUser {
            self.afterLogin()
            return
        }
        
        /*
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
//            return
        }
        
        var isValidToken = false
        let accessToken = UserDefaults.standard.string(forKey: KEY_TOKEN)
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken!)"
        ]
        
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Loading..."
        MKProgress.show()
        
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
                DispatchQueue.main.async {
//                    MBProgressHUD.hide(for: self.view, animated: true)
                    MKProgress.hide()
                    if (isValidToken) {
                        self.afterLogin()
                    }
                }
        }
 */
    }
    
    func getStoryboardWithIdentifier(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller;
    }
}
