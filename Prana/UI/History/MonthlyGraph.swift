//
//  MonthlyGraph.swift
//  Prana
//
//  Created by Guru on 6/26/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

enum MeasurementUnit {
    case inch
    case cm
}

class MonthlyGraph: UIView {

    
    var unit: MeasurementUnit = .inch
    
    var series: [Float] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        backgroundColor = .white
    }
    
    var color: UIColor = .black
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if series.count <= 0 {
            super.draw(rect)
            return
        }
        
        var max = series.max()!
        if max <= 0 { max = 50 }
        
        let tw:CGFloat = 40
        let uw = (width - tw) / CGFloat(series.count - 1)
        let hc: CGFloat = 6
        let xAxisLabelHeight: CGFloat = 20
        let uh = (height - xAxisLabelHeight) / hc
        
        let th: CGFloat = 20
        let bw: CGFloat = 5
        let xw: CGFloat = 20
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        var attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.bold(ofSize: 13),
            .foregroundColor: UIColor(hexString: "#79859f")
        ]
        
        var attributedString: NSAttributedString!
        var stringRect: CGRect!
        
        for i in 0..<Int(hc) {
            if unit == .inch {
                attributedString = NSAttributedString(string: "\(roundFloat(Float(max) / Float(hc - 1) * Float(i), point: 2))", attributes: attributes)
            } else {
                attributedString = NSAttributedString(string: "\(roundFloat(Float(max) / Float(hc - 1) * Float(i) * 2.54, point: 2))", attributes: attributes)
            }
            stringRect = CGRect(x: 0, y: height - uh * CGFloat(i) - th - xAxisLabelHeight, width: tw, height: th)
            attributedString.draw(in: stringRect)
        }
        
        attributes = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.regular(ofSize: 11),
            .foregroundColor: UIColor(hexString: "#79859f")
        ]
        
        for i in 0..<series.count {
            let total = series[i]
            let totalR = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0 + tw, y: height - xAxisLabelHeight - (height - xAxisLabelHeight) * CGFloat(total) / CGFloat(max), width: bw, height: (height - xAxisLabelHeight) * CGFloat(total) / CGFloat(max))
            let totalP = UIBezierPath(rect: totalR)
            color.setFill()
            totalP.fill()
            
            if total > 0 {
                attributedString = NSAttributedString(string: "\(i+1)", attributes: attributes)
                stringRect = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - xw / 2.0 + tw, y: height - xAxisLabelHeight, width: xw, height:  xAxisLabelHeight)
                attributedString.draw(in: stringRect)
            }
        }
    }
    

}
