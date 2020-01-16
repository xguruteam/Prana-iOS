//
//  TutorialWearLowerbackViewController.swift
//  Prana
//
//  Created by Luccas on 4/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class TutorialWearLowerbackViewController: UIViewController {

    @IBOutlet weak var btn_next: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        if let nav = self.navigationController {
            nav.viewControllers.remove(at: nav.viewControllers.count - 2)
        }
        
        initView()
    }
    
    func initView() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "app-background")
        imageView.center = view.center
        view.insertSubview(imageView, at: 0)
        view.sendSubviewToBack(imageView)
        
        btn_next.titleLabel?.textAlignment = .center
    }

    @IBAction func onNextClick(_ sender: UIButton) {
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
        let vc = Utils.getStoryboardWithIdentifier(name:"TutorialTraining", identifier: "LiveFeedViewController") as! LiveFeedViewController
        vc.isLowerBack = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoConnectViewController() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ConnectViewController") as! ConnectViewController
        firstVC.isTutorial = false
        firstVC.completionHandler = { [unowned self] in
            self.gotoLiveGraph()
        }
        
        let navVC = UINavigationController(rootViewController: firstVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
}
