//
//  SuperViewController.swift
//  Prana
//
//  Created by Guru on 6/23/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SuperViewController: UIViewController {

    deinit {
        print("\(self.description) deinit")
    }
    
    var dataController: DataController {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return DataController() }
        
        return appDelegate.dataController
    }
    
    var notificationCenter: Notifications {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return Notifications()
        }
        
        return appDelegate.notifications
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func getViewController(storyboard: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller;
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
