//
//  SessionDetailViewController.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import MKProgress

class SessionDetailViewController: SuperViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    let containerView: UIView = {
        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = UIFont.medium(ofSize: 15)
        label.textColor = UIColor(hexString: "#45494d")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Session Details"
        label.font = UIFont.medium(ofSize: 15)
        label.textColor = UIColor(hexString: "#45494d")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic-back"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let lblOverview: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold(ofSize: 16)
        label.textColor = UIColor(hexString: "#79859f")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let rrGraph: Chart = {
        let graph = Chart()
        graph.labelFont = UIFont.bold(ofSize: 13)
        graph.labelColor = UIColor(hexString: "#79859f")
        graph.axesColor = UIColor(hexString: "#ced3dc")
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.yLabelsFormatter = { index, value -> String in
            return "\(roundFloat(Float(value), point: 2))"
        }
        return graph
    }()
    
    let breathSummaryView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "#79859f")
        label.font = UIFont.medium(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let avgEILavel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#79859f")
        label.font = UIFont.medium(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let eiGraph: Chart = {
        let graph = Chart()
        graph.labelFont = UIFont.bold(ofSize: 13)
        graph.labelColor = UIColor(hexString: "#79859f")
        graph.axesColor = UIColor(hexString: "#ced3dc")
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.yLabelsFormatter = { index, value -> String in
            return "\(roundFloat(Float(value), point: 2))"
        }
        return graph
    }()
    
    let eiGraphScroll: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    let rrGraphScroll: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    let postureView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let postureBar: PostureBar = {
        let bar = PostureBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.clear
        return bar
    }()
    
    let postureScroll: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    let postureBar2: PostureBar2 = {
        let bar = PostureBar2()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.clear
        return bar
    }()
    
    let summaryView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "#79859f")
        label.font = UIFont.medium(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rrGraph2: RRGraph = {
        let graph = RRGraph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.backgroundColor = .clear
        graph.clipsToBounds = false
        return graph
    }()
    
    @objc func onBack() {
        guard let _ = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        tableView.tableHeaderView = containerView
        if type == .session {
            containerView.bounds.size.height = 649
        } else {
            containerView.bounds.size.height = 649
        }
        
        containerView.addSubview(subTitleLabel)
        subTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        containerView.addSubview(backButton)
        backButton.centerYAnchor.constraint(equalTo: subTitleLabel.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        
        
        containerView.addSubview(lblOverview)
        lblOverview.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 10).isActive = true
        lblOverview.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        
        if type == .session {
            
            if session.kind == 0 {
                containerView.addSubview(rrGraphScroll)
                rrGraphScroll.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 20).isActive = true
                rrGraphScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                rrGraphScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                rrGraphScroll.heightAnchor.constraint(equalToConstant: 200).isActive = true
                rrGraphScroll.addSubview(rrGraph2)
                
                let rrLabel = UILabel()
                rrLabel.text = "RR"
                rrLabel.textColor = UIColor(hexString: "#79859f")
                rrLabel.font = UIFont.bold(ofSize: 13)
                containerView.addSubview(rrLabel)
                rrLabel.translatesAutoresizingMaskIntoConstraints = false
                rrLabel.topAnchor.constraint(equalTo: rrGraphScroll.topAnchor, constant: -20).isActive = true
                rrLabel.leftAnchor.constraint(equalTo: rrGraphScroll.leftAnchor, constant: 0).isActive = true
                
                var minLabel = UILabel()
                minLabel.text = "Mins"
                minLabel.textColor = UIColor(hexString: "#79859f")
                minLabel.font = UIFont.bold(ofSize: 13)
                containerView.addSubview(minLabel)
                minLabel.translatesAutoresizingMaskIntoConstraints = false
                minLabel.topAnchor.constraint(equalTo: rrGraphScroll.bottomAnchor, constant: 0).isActive = true
                minLabel.rightAnchor.constraint(equalTo: rrGraphScroll.rightAnchor, constant: 0).isActive = true
                
                containerView.addSubview(breathSummaryView)
                breathSummaryView.topAnchor.constraint(equalTo: rrGraphScroll.bottomAnchor, constant: 20).isActive = true
                breathSummaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                breathSummaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                
                containerView.addSubview(postureView)
                postureView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.topAnchor.constraint(equalTo: breathSummaryView.bottomAnchor, constant: 20).isActive = true
                postureView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                
                containerView.addSubview(postureScroll)
                postureScroll.topAnchor.constraint(equalTo: postureView.bottomAnchor, constant: 20).isActive = true
                postureScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                postureScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                postureScroll.heightAnchor.constraint(equalToConstant: 40).isActive = true
                postureScroll.addSubview(postureBar2)
                
                minLabel = UILabel()
                minLabel.text = "Mins"
                minLabel.textColor = UIColor(hexString: "#79859f")
                minLabel.font = UIFont.bold(ofSize: 13)
                containerView.addSubview(minLabel)
                minLabel.translatesAutoresizingMaskIntoConstraints = false
                minLabel.topAnchor.constraint(equalTo: postureScroll.bottomAnchor, constant: 0).isActive = true
                minLabel.rightAnchor.constraint(equalTo: postureScroll.rightAnchor, constant: 0).isActive = true
                
                containerView.addSubview(summaryView)
                summaryView.topAnchor.constraint(equalTo: postureScroll.bottomAnchor, constant: 20).isActive = true
                summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            } else if session.kind == 1 {
                containerView.addSubview(rrGraphScroll)
                rrGraphScroll.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 20).isActive = true
                rrGraphScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                rrGraphScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                rrGraphScroll.heightAnchor.constraint(equalToConstant: 200).isActive = true
                rrGraphScroll.addSubview(rrGraph2)
                
                let rrLabel = UILabel()
                rrLabel.text = "RR"
                rrLabel.textColor = UIColor(hexString: "#79859f")
                rrLabel.font = UIFont.bold(ofSize: 13)
                containerView.addSubview(rrLabel)
                rrLabel.translatesAutoresizingMaskIntoConstraints = false
                rrLabel.topAnchor.constraint(equalTo: rrGraphScroll.topAnchor, constant: -20).isActive = true
                rrLabel.leftAnchor.constraint(equalTo: rrGraphScroll.leftAnchor, constant: 0).isActive = true
                
                let minLabel = UILabel()
                minLabel.text = "Mins"
                minLabel.textColor = UIColor(hexString: "#79859f")
                minLabel.font = UIFont.bold(ofSize: 13)
                containerView.addSubview(minLabel)
                minLabel.translatesAutoresizingMaskIntoConstraints = false
                minLabel.topAnchor.constraint(equalTo: rrGraphScroll.bottomAnchor, constant: 0).isActive = true
                minLabel.rightAnchor.constraint(equalTo: rrGraphScroll.rightAnchor, constant: 0).isActive = true
                
                containerView.addSubview(summaryView)
                summaryView.topAnchor.constraint(equalTo: rrGraphScroll.bottomAnchor, constant: 40).isActive = true
                summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            } else {
                containerView.addSubview(postureView)
                postureView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 20).isActive = true
                postureView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                
                containerView.addSubview(postureScroll)
                postureScroll.topAnchor.constraint(equalTo: postureView.bottomAnchor, constant: 20).isActive = true
                postureScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                postureScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                postureScroll.heightAnchor.constraint(equalToConstant: 40).isActive = true
                postureScroll.addSubview(postureBar2)
                
                let minLabel = UILabel()
                minLabel.text = "Mins"
                minLabel.textColor = UIColor(hexString: "#79859f")
                minLabel.font = UIFont.bold(ofSize: 13)
                containerView.addSubview(minLabel)
                minLabel.translatesAutoresizingMaskIntoConstraints = false
                minLabel.topAnchor.constraint(equalTo: postureScroll.bottomAnchor, constant: 0).isActive = true
                minLabel.rightAnchor.constraint(equalTo: postureScroll.rightAnchor, constant: 0).isActive = true
                
                containerView.addSubview(summaryView)
                summaryView.topAnchor.constraint(equalTo: postureScroll.bottomAnchor, constant: 20).isActive = true
                summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            }
        } else {
            containerView.addSubview(rrGraphScroll)
            rrGraphScroll.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 10).isActive = true
            rrGraphScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            rrGraphScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            rrGraphScroll.heightAnchor.constraint(equalToConstant: 150).isActive = true
            rrGraphScroll.addSubview(rrGraph)
            
            let rrLabel = UILabel()
            rrLabel.text = "RR"
            rrLabel.textColor = UIColor(hexString: "#79859f")
            rrLabel.font = UIFont.bold(ofSize: 13)
            containerView.addSubview(rrLabel)
            rrLabel.translatesAutoresizingMaskIntoConstraints = false
            rrLabel.topAnchor.constraint(equalTo: rrGraphScroll.topAnchor, constant: -20).isActive = true
            rrLabel.leftAnchor.constraint(equalTo: rrGraphScroll.leftAnchor, constant: 0).isActive = true
            
            var minLabel = UILabel()
            minLabel.text = "Mins"
            minLabel.textColor = UIColor(hexString: "#79859f")
            minLabel.font = UIFont.bold(ofSize: 13)
            containerView.addSubview(minLabel)
            minLabel.translatesAutoresizingMaskIntoConstraints = false
            minLabel.topAnchor.constraint(equalTo: rrGraphScroll.bottomAnchor, constant: 0).isActive = true
            minLabel.rightAnchor.constraint(equalTo: rrGraphScroll.rightAnchor, constant: 0).isActive = true
            
            containerView.addSubview(breathSummaryView)
            breathSummaryView.topAnchor.constraint(equalTo: rrGraphScroll.bottomAnchor, constant: 0).isActive = true
            breathSummaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            breathSummaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true

            containerView.addSubview(eiGraphScroll)
            eiGraphScroll.topAnchor.constraint(equalTo: breathSummaryView.bottomAnchor, constant: 30).isActive = true
            eiGraphScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            eiGraphScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            eiGraphScroll.heightAnchor.constraint(equalToConstant: 150).isActive = true
            eiGraphScroll.addSubview(eiGraph)
            
            let eiLabel = UILabel()
            eiLabel.text = "E/I"
            eiLabel.textColor = UIColor(hexString: "#79859f")
            eiLabel.font = UIFont.bold(ofSize: 13)
            containerView.addSubview(eiLabel)
            eiLabel.translatesAutoresizingMaskIntoConstraints = false
            eiLabel.topAnchor.constraint(equalTo: eiGraphScroll.topAnchor, constant: -20).isActive = true
            eiLabel.leftAnchor.constraint(equalTo: eiGraphScroll.leftAnchor, constant: 0).isActive = true
            
            minLabel = UILabel()
            minLabel.text = "Mins"
            minLabel.textColor = UIColor(hexString: "#79859f")
            minLabel.font = UIFont.bold(ofSize: 13)
            containerView.addSubview(minLabel)
            minLabel.translatesAutoresizingMaskIntoConstraints = false
            minLabel.topAnchor.constraint(equalTo: eiGraphScroll.bottomAnchor, constant: 0).isActive = true
            minLabel.rightAnchor.constraint(equalTo: eiGraphScroll.rightAnchor, constant: 0).isActive = true
            
            containerView.addSubview(avgEILavel)
            avgEILavel.topAnchor.constraint(equalTo: eiGraphScroll.bottomAnchor, constant: 0).isActive = true
            avgEILavel.leftAnchor.constraint(equalTo: eiGraphScroll.leftAnchor, constant: 0).isActive = true

            
            containerView.addSubview(postureView)
            postureView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            postureView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            postureView.topAnchor.constraint(equalTo: eiGraphScroll.bottomAnchor, constant: 10).isActive = true
            postureView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            
            containerView.addSubview(postureScroll)
            postureScroll.topAnchor.constraint(equalTo: postureView.bottomAnchor, constant: 10).isActive = true
            postureScroll.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            postureScroll.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            postureScroll.heightAnchor.constraint(equalToConstant: 40).isActive = true
            postureScroll.addSubview(postureBar)
            
            minLabel = UILabel()
            minLabel.text = "Mins"
            minLabel.textColor = UIColor(hexString: "#79859f")
            minLabel.font = UIFont.bold(ofSize: 13)
            containerView.addSubview(minLabel)
            minLabel.translatesAutoresizingMaskIntoConstraints = false
            minLabel.topAnchor.constraint(equalTo: postureScroll.bottomAnchor, constant: 0).isActive = true
            minLabel.rightAnchor.constraint(equalTo: postureScroll.rightAnchor, constant: 0).isActive = true
            
            containerView.addSubview(summaryView)
            summaryView.topAnchor.constraint(equalTo: postureScroll.bottomAnchor, constant: 10).isActive = true
            summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
        }
        
        
        rrGraphScroll.delegate = self
        eiGraphScroll.delegate = self
        postureScroll.delegate = self
        
        renderSessionData()
        
        guard isFirstLoadingSession else {
            return
        }
        MKProgress.show()
        dataController.sync { (success) in
            MKProgress.hide()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == .session {
            if session.kind == 0 || session.kind == 1 {
                rrGraph2.frame = CGRect(x: 0.0, y: 0.0, width: rrGraphScroll.frame.width * CGFloat(rrPages), height: rrGraphScroll.frame.height)
                rrGraph2.setNeedsDisplay()
                rrGraphScroll.contentSize = rrGraph2.frame.size
            }
            if session.kind == 0 || session.kind == 2 {
                postureBar2.frame = CGRect(x: 0.0, y: 0.0, width: postureScroll.frame.width * CGFloat(rrPages), height: postureScroll.frame.height)
                postureScroll.contentSize = postureBar2.frame.size
            }
            postureBar2.setNeedsDisplay()
        } else {
            eiGraph.frame = CGRect(x: 0.0, y: 0.0, width: eiGraphScroll.frame.width * CGFloat(eiPages), height: eiGraphScroll.frame.height)
            eiGraphScroll.contentSize = eiGraph.frame.size
            rrGraph.frame = CGRect(x: 0.0, y: 0.0, width: rrGraphScroll.frame.width * CGFloat(eiPages), height: rrGraphScroll.frame.height)
            rrGraphScroll.contentSize = rrGraph.frame.size
            postureBar.frame = CGRect(x: 0.0, y: 0.0, width: postureScroll.frame.width * CGFloat(eiPages), height: postureScroll.frame.height)
            postureScroll.contentSize = postureBar.frame.size
            postureBar.setNeedsDisplay()
        }
    }
    
    var type: SessionType = .session
    
    var session: TrainingSession!
    var passive: PassiveSession!
    
    var eiPages: CGFloat = 0
    var rrPages: CGFloat = 0
    
    var isFirstLoadingSession = false
    
    func renderSessionData() {
        if type == .session {
            let dateDescription = session.startedAt.dateTimeString()
            let kindDescription = session.kindString
            let typeDescription = session.typeString
            lblOverview.text =
            """
            \(dateDescription)
            Training: \(kindDescription)
            \(typeDescription)
            """

            var duration = session.duration / 60
            if session.duration > duration * 60 {
                duration += 1
            }
            
            var pages = Int(session.duration) / 300
            
            if session.duration > pages * 300 {
                pages += 1
            }
            rrPages = CGFloat(pages)
            
            if session.kind == 0 || session.kind == 1 {
                
                rrGraph2.session = session
                
                if session.kind == 0 {
                    breathSummaryView.text = session.breathingSummary
                } else {
                    summaryView.text = session.breathingSummary
                }
            }
            
            if session.kind == 0 || session.kind == 2 {
                if session.wearing == 0 {
                    postureView.image = UIImage(named: "sit (1)")
                } else {
                    postureView.image = UIImage(named: "stand (1)")
                }
                
                postureBar2.session = session
                if session.kind == 0 {
                    postureBar2.numberOfPages = Int(rrPages)
                } else {
                    postureBar2.numberOfPages = 1
                }
                
                summaryView.text = session.postureSummary
            }
            
        } else {
            let dateDescription = passive.startedAt.dateTimeString()
            lblOverview.text =
            """
            \(dateDescription)
            Tracking
            """
            
            var duration = passive.duration / 60
            if duration < 5 { duration = 5 }
            var xlabels = (0...duration).map { Double($0) }
            if passive.duration > duration * 60 {
                xlabels.append(Double(duration) + 1)
            }
            rrGraph.xLabels = xlabels
            
            var data = passive.breaths.map { (breath) -> (Double, Double) in
                return (Double(breath.timeStamp) / 60.0, breath.oneMinuteRR)
            }
            
            var series = ChartSeries(data: data)
            series.color = UIColor(hexString: "#2BB7B8")
            series.area = true
            
            rrGraph.add(series)
            
            eiGraph.xLabels = xlabels
            
            data = passive.breaths.map { (breath) -> (Double, Double) in
                return (Double(breath.timeStamp) / 60.0, breath.eiRatio)
            }
            
            series = ChartSeries(data: data)
            series.color = UIColor(hexString: "#2BB7B8")
            series.area = true
            
            eiGraph.add(series)
            eiPages = CGFloat(xlabels.count - 1) / 5.0
            
            let (avgEI, _) = passive.sumEIRatio()
            avgEILavel.text = "Session Avg. EI : \(Float(avgEI))"
            
            
            if passive.wearing == 0 {
                postureView.image = UIImage(named: "sit (1)")
            } else {
                postureView.image = UIImage(named: "stand (1)")
            }
            
            postureBar.duration = passive.duration
            postureBar.slouches = passive.slouches
            postureBar.numberOfPages = Int(eiPages)
            
            breathSummaryView.text = passive.breathSummary
            summaryView.text = passive.postureSummary
        }
    }
}

extension SessionDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != rrGraphScroll {
            rrGraphScroll.contentOffset = scrollView.contentOffset
        }
        
        if scrollView != eiGraphScroll {
            eiGraphScroll.contentOffset = scrollView.contentOffset
        }
        
        if scrollView != postureScroll {
            postureScroll.contentOffset = scrollView.contentOffset
        }
    }
}
