//
//  TapBarViewController.swift
//  Prana
//
//  Created by Luccas on 4/12/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class TapBarViewController: UITabBarController {
    
    @IBOutlet weak var _tabBar: UITabBar!
    
    var customTabBar: UIView!
    var btnTraining: UIButton!
    var btnMeasure: UIButton!
    var btnHistory: UIButton!
    var btnSettings: UIButton!
    
    private var width: CGFloat {
        return view.bounds.width
    }
    
    private var height: CGFloat {
        return view.bounds.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        
        insertCustomTabBar()
        
        buttonClicked(btnTraining)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.dataController.sync { (success) in
            print(success)
        }
    }
    
    func initView() {
        _tabBar.borderWidth = 0.0
    }
    
    func insertCustomTabBar() {
        customTabBar = UIView(frame: CGRect(x: 0.0, y: height-49.0, width: width, height: 49.0))
        customTabBar.backgroundColor = .white
        
        btnTraining = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: width/4.0, height: 49.0))
        btnTraining.setImage(UIImage(named: "tap-breath"), for: .normal)
        btnTraining.contentMode = .center
        btnTraining.imageView?.contentMode = .scaleAspectFit
        customTabBar.addSubview(btnTraining)
        btnTraining.tag = 0
        btnTraining.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        btnMeasure = UIButton(frame: CGRect(x: width/4.0, y: 0.0, width: width/4.0, height: 49.0))
        btnMeasure.setImage(UIImage(named: "tap-measure"), for: .normal)
        btnMeasure.contentMode = .center
        btnMeasure.imageView?.contentMode = .scaleAspectFit
        customTabBar.addSubview(btnMeasure)
        btnMeasure.tag = 1
        btnMeasure.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        btnHistory = UIButton(frame: CGRect(x: width*2.0/4.0, y: 0.0, width: width/4.0, height: 49.0))
        btnHistory.setImage(UIImage(named: "tap-history"), for: .normal)
        btnHistory.contentMode = .center
        btnHistory.imageView?.contentMode = .scaleAspectFit
        customTabBar.addSubview(btnHistory)
        btnHistory.tag = 2
        btnHistory.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        btnSettings = UIButton(frame: CGRect(x: width*3.0/4.0, y: 0.0, width: width/4.0, height: 49.0))
        btnSettings.setImage(UIImage(named: "tap-settings"), for: .normal)
        btnSettings.contentMode = .center
        btnSettings.imageView?.contentMode = .scaleAspectFit
        customTabBar.addSubview(btnSettings)
        btnSettings.tag = 3
        btnSettings.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        self.view.addSubview(customTabBar)
    }
    
    @objc func buttonClicked(_ sender: UIButton?) {
        selectedIndex = sender!.tag
        
        applyButtonsUnselect()
        
        let colors = [UIColor(red: 76.0/256.0, green: 227.0/256.0, blue: 218.0/256.0, alpha: 1.0), UIColor(red: 26.0/256.0, green: 150.0/256.0, blue: 159.0/256.0, alpha: 1.0)]
        let points = [CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0)]
        applyButtonGradient(button: sender!, colors: colors, points: points)
        
        switch sender!.tag {
        case 0:
            sender!.setImage(UIImage(named: "tap-breath-o"), for: .normal)
            applyButtonRound(button: sender!, corners: [.bottomRight, .topRight], size: 5)
        case 1:
            sender!.setImage(UIImage(named: "tap-measure-o"), for: .normal)
            applyButtonRound(button: sender!, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], size: 5)
        case 2:
            sender!.setImage(UIImage(named: "tap-history-o"), for: .normal)
            applyButtonRound(button: sender!, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], size: 5)
        case 3:
            sender!.setImage(UIImage(named: "tap-settings-o"), for: .normal)
            applyButtonRound(button: sender!, corners: [.bottomLeft, .topLeft], size: 5)
        default:
            break
        }
    }
    
    func applyButtonsUnselect() {
        let mask = CAShapeLayer()
        mask.bounds = btnTraining.frame
        mask.position = btnTraining.center
        mask.path = UIBezierPath(roundedRect: btnTraining.bounds, byRoundingCorners: [.bottomLeft , .bottomRight , .topLeft, .topRight], cornerRadii: CGSize(width: 0.0, height: 0.0)).cgPath
        
        btnTraining.setImage(UIImage(named: "tap-breath"), for: .normal)
        btnTraining.layer.sublayers?.forEach {
            if $0.name == "active" {
                $0.removeFromSuperlayer()
            }
        }
        btnTraining.layer.mask = mask
        
        btnMeasure.setImage(UIImage(named: "tap-measure"), for: .normal)
        btnMeasure.layer.sublayers?.forEach {
            if $0.name == "active" {
                $0.removeFromSuperlayer()
            }
        }
        btnMeasure.layer.mask = mask
        
        btnHistory.setImage(UIImage(named: "tap-history"), for: .normal)
        btnHistory.layer.sublayers?.forEach {
            if $0.name == "active" {
                $0.removeFromSuperlayer()
            }
        }
        btnHistory.layer.mask = mask
        
        btnSettings.setImage(UIImage(named: "tap-settings"), for: .normal)
        btnSettings.layer.sublayers?.forEach {
            if $0.name == "active" {
                $0.removeFromSuperlayer()
            }
        }
        btnSettings.layer.mask = mask
    }
    
    func applyButtonGradient(button: UIButton, colors: [UIColor], points: [CGPoint]) {
        let gradient = CAGradientLayer()
        gradient.frame = button.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = points[1]
        gradient.endPoint = points[0]
        gradient.name = "active"
        
        button.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyButtonRound(button: UIButton, corners: UIRectCorner, size: CGFloat) {
        let mask = CAShapeLayer()
        mask.bounds = button.frame
        mask.position = button.center
        mask.path = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: size, height: size)).cgPath
        
        button.layer.mask = mask
    }
}
