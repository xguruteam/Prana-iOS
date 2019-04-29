//
//  TutorialBuzzerViewController.swift
//  Prana
//
//  Created by Luccas on 4/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class TutorialBuzzerViewController: UIViewController {

    @IBOutlet weak var btn_next: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        initView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initView() {
//        let background = UIImage(named: "app-background")
//        let imageView = UIImageView(frame: view.bounds)
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.image = background
//        imageView.center = view.center
//        view.insertSubview(imageView, at: 0)
//        view.sendSubviewToBack(imageView)
        
        btn_next.titleLabel?.textAlignment = .center
    }

    @IBAction func onNext(_ sender: Any) {
        let vc = Utils.getStoryboardWithIdentifier(identifier:"BuzzerTrainingViewController") as! BuzzerTrainingViewController
        vc.isTutorial = true
        vc.sessionKind = 0
        vc.sessionWearing = 0
        vc.sessionDuration = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
