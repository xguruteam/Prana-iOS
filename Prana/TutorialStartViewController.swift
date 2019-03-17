//
//  TutorialStartViewController.swift
//  Prana
//
//  Created by Dev on 3/13/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

class TutorialStartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLogoutClick(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
        UserDefaults.standard.removeObject(forKey: KEY_EXPIREAT)
        UserDefaults.standard.removeObject(forKey: KEY_REMEMBERME)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onStartTutorialClick(_ sender: Any) {
        
    }
    
    @IBAction func onSkipTutorialClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Confirm", message:
            "Are you sure you wish to skip the tutorial?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (_) in
            let firstVC = Utils.getStoryboardWithIdentifier(identifier: "FirstViewController")
            let navVC = UINavigationController(rootViewController: firstVC)
            self.present(navVC, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
