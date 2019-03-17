//
//  TutorialEndViewController.swift
//  Prana
//
//  Created by Dev on 3/14/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

class TutorialEndViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onNextClick(_ sender: Any) {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "FirstViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
}
