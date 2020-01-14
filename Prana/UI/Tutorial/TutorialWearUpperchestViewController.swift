//
//  TutorialWearUpperchestViewController.swift
//  Prana
//
//  Created by Luccas on 4/3/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class TutorialWearUpperchestViewController: UIViewController {

    @IBOutlet weak var btn_next: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        initView()
    }

    func initView() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "app-background")
        imageView.center = view.center
        view.insertSubview(imageView, at: 0)
        view.sendSubviewToBack(imageView)
        
        btn_next.titleLabel?.textAlignment = .center
    }

    @IBAction func onNext(_ sender: Any) {
        if PranaDeviceManager.shared.isConnected {
            gotoLiveGraph()
            return
        }
        
        gotoConnectViewController()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotoLiveGraph() {
        let vc = Utils.getStoryboardWithIdentifier(name: "Tutorial", identifier: "LiveFeedViewController") as! LiveFeedViewController
        vc.isLowerBack = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoConnectViewController() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ConnectViewController") as! ConnectViewController
        firstVC.isTutorial = false
        firstVC.completionHandler = { [unowned self] in
            self.gotoLiveGraph()
        }

        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
}
