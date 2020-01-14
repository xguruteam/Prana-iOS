//
//  TutorialStartViewController.swift
//  Prana
//
//  Created by Luccas on 3/13/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

class TutorialStartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
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
    }
    
    @IBAction func onLogoutClick(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
        UserDefaults.standard.removeObject(forKey: KEY_EXPIREAT)
        UserDefaults.standard.removeObject(forKey: KEY_REMEMBERME)
        UserDefaults.standard.synchronize()
        
        if PranaDeviceManager.shared.isConnected {
            PranaDeviceManager.shared.stopGettingLiveData()
            PranaDeviceManager.shared.disconnect()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            
        }
    }
    
    @IBAction func onSkipTutorialClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Confirm", message:
            "Are you sure you wish to skip the tutorial?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (_) in
            self.dismiss(animated: false) {
                NotificationCenter.default.post(name: .tutorialDidEnd, object: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
