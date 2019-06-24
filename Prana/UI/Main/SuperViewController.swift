//
//  SuperViewController.swift
//  Prana
//
//  Created by Guru on 6/23/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SuperViewController: UIViewController {

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
