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
    
    @IBOutlet weak var breathCircle: PranaCircleProgressView!
    @IBOutlet weak var lblMindfulBreathTime: UILabel!
    @IBOutlet weak var lblBreathResult: UILabel!
    @IBOutlet weak var lblBreathGoal: UILabel!
    
    @IBOutlet weak var postureCircle: PranaCircleProgressView!
    @IBOutlet weak var lblUprightPostureTime: UILabel!
    @IBOutlet weak var lblPostureResult: UILabel!
    @IBOutlet weak var lblPostureGoal: UILabel!
    
    @IBOutlet weak var btnTraining: UIButton!
    @IBOutlet weak var btnTracking: UIButton!
    @IBOutlet weak var btnLiveGraph: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var dataController: DataController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            dataController = appDelegate.dataController
        }
        
        lblTitle.text = "Today's Achievements"
        
        
//        getTrainSummary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataController?.programType > 1 {
            lblMindfulBreathTime.text = "0"
            lblBreathResult.text = " "
            lblBreathGoal.text = "Set up your Training"
            lblUprightPostureTime.text = "0"
            lblPostureResult.text = " "
            lblPostureGoal.text = "Set up your Training"
            
            breathCircle.progress = 0.0
            postureCircle.progress = 0.0
        }
        else {
            lblMindfulBreathTime.text = "0"
            lblBreathResult.text = "0% Mindful"
            lblUprightPostureTime.text = "0"
            lblPostureResult.text = "0% Upright"
            lblBreathGoal.text = "\(dataController?.breathingGoals ?? 0) mins"
            lblPostureGoal.text = "\(dataController?.postureGoals ?? 0) mins"
            
            calculateSummary()
        }
    }
    
    func calculateSummary() {
        if let sessions = dataController?.fetchSessions(), let _ = sessions.first {
            let (breathingElapsed, postureElapsed, mindfulDuration, uprightDuration) = sessions.reduce((0, 0, 0, 0)) { (acc, session) -> (Int, Int, Int, Int) in
                var result = acc
                if session.kind == 1 {
                    result.0 += session.duration
                }
                else if session.kind == 2 {
                    result.1 += session.duration
                }
                else {
                    result.0 += session.duration
                    result.1 += session.duration
                }
                result.2 += session.mindful
                result.3 += session.upright
                
                return result
            }
            
            if breathingElapsed > 0 {
                lblBreathResult.text = "\(mindfulDuration * 100 / breathingElapsed)% Mindful"
            }
            else {
                lblBreathResult.text = "0% Mindful"
            }
        
            if postureElapsed > 0 {
                lblPostureResult.text = "\(uprightDuration * 100 / postureElapsed)% Upright"
            }
            else {
                lblPostureResult.text = "0% Upright"
            }
            
            
            lblMindfulBreathTime.text = "\(breathingElapsed / 60)"
            lblUprightPostureTime.text = "\(postureElapsed / 60)"
            
            breathCircle.progress = CGFloat(breathingElapsed / 60) / CGFloat(dataController!.breathingGoals)
            
            postureCircle.progress = CGFloat(postureElapsed / 60) / CGFloat(dataController!.postureGoals)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.breathCircle.startAnimation()
//                self.postureCircle.startAnimation()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
//                self.breathCircle.startAnimation()
                self.postureCircle.startAnimation()
            })
        }
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
