//
//  TutorialVisualViewController.swift
//  Prana
//
//  Created by Luccas on 4/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class TutorialVisualViewController: UIViewController {

    @IBOutlet weak var btn_next: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onLandscapeViewControllerDismiss), name: .landscapeViewControllerDidDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: .deviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onVisualViewControllerEnd), name: .visualViewControllerEndSession, object: nil)

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    @objc func onLandscapeViewControllerDismiss() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    @objc func onVisualViewControllerEnd() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        let vc = Utils.getStoryboardWithIdentifier(identifier: "TutorialBuzzerViewController")
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func onDeviceOrientationChange() {
        self.setNeedsStatusBarAppearanceUpdate()
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
        let background = UIImage(named: "app-background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.insertSubview(imageView, at: 0)
        view.sendSubviewToBack(imageView)
        
        btn_next.titleLabel?.textAlignment = .center
    }

    @IBAction func onNext(_ sender: Any) {
        let vc = Utils.getStoryboardWithIdentifier(identifier:"VisualTrainingViewController") as! VisualTrainingViewController
        vc.isTutorial = true
        vc.sessionKind = 0
        vc.sessionWearing = 0
        vc.sessionDuration = 1
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
