//
//  TutorialEndViewController.swift
//  Prana
//
//  Created by Luccas on 3/14/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

class TutorialEndViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        if let nav = self.navigationController {
            nav.viewControllers.remove(at: nav.viewControllers.count - 2)
        }
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
    
    @IBAction func onNextClick(_ sender: Any) {
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .tutorialDidEnd, object: nil)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
