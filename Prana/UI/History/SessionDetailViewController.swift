//
//  SessionDetailViewController.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SessionDetailViewController: SuperViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
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
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.textColor = UIColor(hexString: "#45494d")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Session Details"
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
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
        label.font = UIFont(name: "Quicksand-Bold", size: 16)
        label.textColor = UIColor(hexString: "#79859f")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let rrGraph: Chart = {
        let graph = Chart()
        graph.labelFont = UIFont(name: "Quicksand-Bold", size: 13)
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
        label.font = UIFont(name: "Quicksand-Medium", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let eiGraph: Chart = {
        let graph = Chart()
        graph.labelFont = UIFont(name: "Quicksand-Bold", size: 13)
        graph.labelColor = UIColor(hexString: "#79859f")
        graph.axesColor = UIColor(hexString: "#ced3dc")
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.yLabelsFormatter = { index, value -> String in
            return "\(roundFloat(Float(value), point: 2))"
        }
        return graph
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
        bar.backgroundColor = UIColor(hexString: "#5eb839")
        return bar
    }()
    
    let summaryView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "#79859f")
        label.font = UIFont(name: "Quicksand-Medium", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

//        containerView.addSubview(titleLabel)
//        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
//        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
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
                containerView.addSubview(rrGraph)
                rrGraph.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 20).isActive = true
                rrGraph.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                rrGraph.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                rrGraph.heightAnchor.constraint(equalToConstant: 200).isActive = true
                
                let rrLabel = UILabel()
                rrLabel.text = "RR"
                rrLabel.textColor = UIColor(hexString: "#79859f")
                rrLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
                containerView.addSubview(rrLabel)
                rrLabel.translatesAutoresizingMaskIntoConstraints = false
                rrLabel.topAnchor.constraint(equalTo: rrGraph.topAnchor, constant: -20).isActive = true
                rrLabel.leftAnchor.constraint(equalTo: rrGraph.leftAnchor, constant: 0).isActive = true
                
                let minLabel = UILabel()
                minLabel.text = "Mins"
                minLabel.textColor = UIColor(hexString: "#79859f")
                minLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
                containerView.addSubview(minLabel)
                minLabel.translatesAutoresizingMaskIntoConstraints = false
                minLabel.topAnchor.constraint(equalTo: rrGraph.bottomAnchor, constant: 0).isActive = true
                minLabel.rightAnchor.constraint(equalTo: rrGraph.rightAnchor, constant: 0).isActive = true
                
                containerView.addSubview(breathSummaryView)
                breathSummaryView.topAnchor.constraint(equalTo: rrGraph.bottomAnchor, constant: 20).isActive = true
                breathSummaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                breathSummaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                
                containerView.addSubview(postureView)
                postureView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.topAnchor.constraint(equalTo: breathSummaryView.bottomAnchor, constant: 40).isActive = true
                postureView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                
                containerView.addSubview(postureBar)
                postureBar.topAnchor.constraint(equalTo: postureView.bottomAnchor, constant: 20).isActive = true
                postureBar.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                postureBar.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                postureBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
                
                containerView.addSubview(summaryView)
                summaryView.topAnchor.constraint(equalTo: postureBar.bottomAnchor, constant: 20).isActive = true
                summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            } else if session.kind == 1 {
                containerView.addSubview(rrGraph)
                rrGraph.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 20).isActive = true
                rrGraph.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                rrGraph.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                rrGraph.heightAnchor.constraint(equalToConstant: 200).isActive = true
                
                let rrLabel = UILabel()
                rrLabel.text = "RR"
                rrLabel.textColor = UIColor(hexString: "#79859f")
                rrLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
                containerView.addSubview(rrLabel)
                rrLabel.translatesAutoresizingMaskIntoConstraints = false
                rrLabel.topAnchor.constraint(equalTo: rrGraph.topAnchor, constant: -20).isActive = true
                rrLabel.leftAnchor.constraint(equalTo: rrGraph.leftAnchor, constant: 0).isActive = true
                
                let minLabel = UILabel()
                minLabel.text = "Mins"
                minLabel.textColor = UIColor(hexString: "#79859f")
                minLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
                containerView.addSubview(minLabel)
                minLabel.translatesAutoresizingMaskIntoConstraints = false
                minLabel.topAnchor.constraint(equalTo: rrGraph.bottomAnchor, constant: 0).isActive = true
                minLabel.rightAnchor.constraint(equalTo: rrGraph.rightAnchor, constant: 0).isActive = true
                
                containerView.addSubview(summaryView)
                summaryView.topAnchor.constraint(equalTo: rrGraph.bottomAnchor, constant: 40).isActive = true
                summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            } else {
                containerView.addSubview(postureView)
                postureView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                postureView.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 20).isActive = true
                postureView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                
                containerView.addSubview(postureBar)
                postureBar.topAnchor.constraint(equalTo: postureView.bottomAnchor, constant: 20).isActive = true
                postureBar.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                postureBar.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
                postureBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
                
                containerView.addSubview(summaryView)
                summaryView.topAnchor.constraint(equalTo: postureBar.bottomAnchor, constant: 20).isActive = true
                summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
                summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            }
        } else {
            containerView.addSubview(rrGraph)
            rrGraph.topAnchor.constraint(equalTo: lblOverview.bottomAnchor, constant: 10).isActive = true
            rrGraph.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            rrGraph.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            rrGraph.heightAnchor.constraint(equalToConstant: 150).isActive = true
            
            let rrLabel = UILabel()
            rrLabel.text = "RR"
            rrLabel.textColor = UIColor(hexString: "#79859f")
            rrLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
            containerView.addSubview(rrLabel)
            rrLabel.translatesAutoresizingMaskIntoConstraints = false
            rrLabel.topAnchor.constraint(equalTo: rrGraph.topAnchor, constant: -20).isActive = true
            rrLabel.leftAnchor.constraint(equalTo: rrGraph.leftAnchor, constant: 0).isActive = true
            
            var minLabel = UILabel()
            minLabel.text = "Mins"
            minLabel.textColor = UIColor(hexString: "#79859f")
            minLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
            containerView.addSubview(minLabel)
            minLabel.translatesAutoresizingMaskIntoConstraints = false
            minLabel.topAnchor.constraint(equalTo: rrGraph.bottomAnchor, constant: 0).isActive = true
            minLabel.rightAnchor.constraint(equalTo: rrGraph.rightAnchor, constant: 0).isActive = true
            
            containerView.addSubview(breathSummaryView)
            breathSummaryView.topAnchor.constraint(equalTo: rrGraph.bottomAnchor, constant: 16).isActive = true
            breathSummaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            breathSummaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true

            containerView.addSubview(eiGraph)
            eiGraph.topAnchor.constraint(equalTo: breathSummaryView.bottomAnchor, constant: 40).isActive = true
            eiGraph.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            eiGraph.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            eiGraph.heightAnchor.constraint(equalToConstant: 150).isActive = true
            
            let eiLabel = UILabel()
            eiLabel.text = "E/I"
            eiLabel.textColor = UIColor(hexString: "#79859f")
            eiLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
            containerView.addSubview(eiLabel)
            eiLabel.translatesAutoresizingMaskIntoConstraints = false
            eiLabel.topAnchor.constraint(equalTo: eiGraph.topAnchor, constant: -20).isActive = true
            eiLabel.leftAnchor.constraint(equalTo: eiGraph.leftAnchor, constant: 0).isActive = true
            
            minLabel = UILabel()
            minLabel.text = "Mins"
            minLabel.textColor = UIColor(hexString: "#79859f")
            minLabel.font = UIFont(name: "Quicksand-Bold", size: 13)
            containerView.addSubview(minLabel)
            minLabel.translatesAutoresizingMaskIntoConstraints = false
            minLabel.topAnchor.constraint(equalTo: eiGraph.bottomAnchor, constant: 0).isActive = true
            minLabel.rightAnchor.constraint(equalTo: eiGraph.rightAnchor, constant: 0).isActive = true
            
            
            containerView.addSubview(postureView)
            postureView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            postureView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            postureView.topAnchor.constraint(equalTo: eiGraph.bottomAnchor, constant: 10).isActive = true
            postureView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            
            containerView.addSubview(postureBar)
            postureBar.topAnchor.constraint(equalTo: postureView.bottomAnchor, constant: 10).isActive = true
            postureBar.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            postureBar.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
            postureBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            containerView.addSubview(summaryView)
            summaryView.topAnchor.constraint(equalTo: postureBar.bottomAnchor, constant: 10).isActive = true
            summaryView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
            summaryView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
        }
        
        renderSessionData()
    }
    
    var type: SessionType = .session
    
    var session: TrainingSession!
    var passive: PassiveSession!
    
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

            if session.kind == 0 || session.kind == 1 {
                let duration = session.duration / 60
                var xlabels = (0...duration).map { Double($0) }
                xlabels.append(Double(duration) + 0.5)
                rrGraph.xLabels = xlabels
                
                var series: [([(Double, Double)], Bool)] = []
                var segment: [(Double, Double)] = []
                var prevMindful = false
                var targetRRs: [(Double, Double)] = []
                session.breaths.enumerated().forEach { (i, breath) in
                    let value = (Double(breath.timeStamp) / 60.0, breath.respRate)
                    segment.append(value)
                    
                    let targetRRValue = (Double(breath.timeStamp) / 60.0, breath.targetRate)
                    targetRRs.append(targetRRValue)
                    
                    if i == 0 {
                        prevMindful = breath.isMindful
                    }
                    
                    if prevMindful == breath.isMindful {
                        if i == session.breaths.count - 1 {
                            series.append((segment, prevMindful))
                        }
                    } else {
                        series.append((segment, prevMindful))
                        if i < session.breaths.count - 1 {
                            segment = [value]
                            prevMindful = breath.isMindful
                        }
                    }
                }
                
                series.forEach { (line) in
                    let (data, isMindful) = line
                    let series = ChartSeries(data: data)
                    if isMindful {
                        series.color = UIColor(hexString: "#5eb839")
                    } else {
                        series.color = UIColor(hexString: "#ff0000")
                    }
                    series.area = true
                    rrGraph.add(series)
                }
                
                let targetRRSeries = ChartSeries(data: targetRRs)
                targetRRSeries.color = UIColor(hexString: "#0000ff")
                targetRRSeries.area = false
                rrGraph.add(targetRRSeries)
                
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
                
                postureBar.duration = session.duration
                postureBar.slouches = session.slouches
                
                summaryView.text = session.postureSummary
            }
            
        } else {
            let dateDescription = passive.startedAt.dateTimeString()
            lblOverview.text =
            """
            \(dateDescription)
            Tracking
            """
            
            let duration = passive.duration / 60
            var xlabels = (0...duration).map { Double($0) }
            xlabels.append(Double(duration) + 0.5)
            rrGraph.xLabels = xlabels
            
            var data = passive.breaths.map { (breath) -> (Double, Double) in
                return (Double(breath.timeStamp) / 60.0, breath.oneMinuteRR)
            }
            
            var series = ChartSeries(data: data)
            series.color = UIColor(hexString: "#5eb839")
            series.area = true
            
            rrGraph.add(series)
            
            eiGraph.xLabels = xlabels
            
            data = passive.breaths.map { (breath) -> (Double, Double) in
                return (Double(breath.timeStamp) / 60.0, breath.eiRatio)
            }
            
            series = ChartSeries(data: data)
            series.color = UIColor(hexString: "#5eb839")
            series.area = true
            
            eiGraph.add(series)
            
            
            if passive.wearing == 0 {
                postureView.image = UIImage(named: "sit (1)")
            } else {
                postureView.image = UIImage(named: "stand (1)")
            }
            
            postureBar.duration = passive.duration
            postureBar.slouches = passive.slouches
            
            breathSummaryView.text = passive.breathSummary
            summaryView.text = passive.postureSummary
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
