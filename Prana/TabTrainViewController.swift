//
//  TabTrainViewController.swift
//  Prana
//
//  Created by Dev on 4/12/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class TabTrainViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var breathCircle: UIView!
    @IBOutlet weak var lblMindfulBreathTime: UILabel!
    @IBOutlet weak var lblBreathResult: UILabel!
    @IBOutlet weak var lblBreathGoal: UILabel!
    
    @IBOutlet weak var postureCircle: UIView!
    @IBOutlet weak var lblUprightPostureTime: UILabel!
    @IBOutlet weak var lblPostureResult: UILabel!
    @IBOutlet weak var lblPostureGoal: UILabel!
    
    @IBOutlet weak var btnTraining: UIButton!
    @IBOutlet weak var btnTracking: UIButton!
    @IBOutlet weak var btnLiveGraph: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        
//        getTrainSummary()
    }
    
    func initView() {
        self.navigationController?.isNavigationBarHidden = true
        
        let background = UIImage(named: "app-background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        container.insertSubview(imageView, at: 0)
        container.sendSubviewToBack(imageView)
        
        applyButtonGradient(button: btnTraining, colors: [UIColor(red: 67.0/256.0, green: 227.0/256.0, blue: 218.0/256.0, alpha: 1.0), UIColor(red: 26.0/256.0, green: 150.0/256.0, blue: 153.0/256.0, alpha: 1.0)], locations: [0.0, 1.0])
        
        applyButtonGradient(button: btnTracking, colors: [UIColor(red: 161.0/256.0, green: 218.0/256.0, blue: 61.0/256.0, alpha: 1.0), UIColor(red: 94.0/256.0, green: 184.0/256.0, blue: 57.0/256.0, alpha: 1.0)], locations: [0.0, 1.0])
        
        //        btnLiveGraph.setTitle("Live Graph", for: .normal)
        //        btnLiveGraph.titleLabel?.textAlignment = .center
        //        btnLiveGraph.titleLabel?.lineBreakMode = .byWordWrapping
        //        btnLiveGraph.titleLabel?.numberOfLines = 2
        applyButtonGradient(button: btnLiveGraph, colors: [UIColor(red: 106.0/256.0, green: 215.0/256.0, blue: 141.0/256.0, alpha: 1.0), UIColor(red: 86.0/256.0, green: 176.0/256.0, blue: 134.0/256.0, alpha: 1.0)], locations: [0.0, 1.0])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func onTrainClick(_ sender: UIButton) {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ProgramsViewController")
//        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(firstVC, animated: true, completion: nil)
    }
    
    @IBAction func onLiveGraphClick(_ sender: UIButton) {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "LiveGraphViewController")
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func getTrainSummary() {
        let gradientRingLayer = WCGraintCircleLayer(bounds: CGRect(origin: CGPoint.zero,size:CGSize(width: 126, height: 126)), position:CGPoint(x: 63, y: 63),fromColor:UIColor.blue, toColor:UIColor.white, linewidth:6.0, toValue:0)
        breathCircle.layer.addSublayer(gradientRingLayer)
        let duration = 1.0
        gradientRingLayer.animateCircle(duration: duration)
    }

    
    func applyButtonGradient(button: UIButton, colors: [UIColor], locations: [NSNumber]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = button.bounds
        gradient.colors = colors.map { $0.withAlphaComponent(1.0).cgColor }
        gradient.locations = locations
        
        button.layer.addSublayer(gradient)
    }
    
}
