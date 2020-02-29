//
//  PostureBar.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PostureBar: UIView {
    
    
    var slouches: [SlouchRecord]!
    var duration: Int!
    var numberOfPages: Int!
    let axisLineWidth: CGFloat = 0.5
    let bottomPadding: CGFloat = 20

    let axisTextAttribute: [NSAttributedString.Key : Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont(name: "Quicksand", size: 12) as Any,
            .foregroundColor: UIColor(hexString: "#79859f")
        ]
        return attributes
    }()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let unit = CGFloat(width) / CGFloat(numberOfPages * 5 * 60)
        let bpath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(duration) * unit, height: height - bottomPadding))
        UIColor(hexString: "#5eb839").setFill()
        bpath.fill()

        for slouch in slouches {
            let x = CGFloat(slouch.timeStamp) * unit
            let w = CGFloat(slouch.duration) * unit
            let path = UIBezierPath(rect: CGRect(x: x, y: 0, width: w, height: height - bottomPadding))
            UIColor(hexString: "#ff0000").setFill()
            path.fill()
        }
        
        drawVerticalLines()
        drawXAxisLabels()
        drawOutbox()
    }
    
    func drawOutbox() {
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: axisLineWidth, y: height - bottomPadding))
        path.addLine(to: CGPoint(x: width - axisLineWidth, y: height - bottomPadding))
        path.addLine(to: CGPoint(x: width - axisLineWidth, y: axisLineWidth))
        path.addLine(to: CGPoint.zero)
        path.lineWidth = axisLineWidth
        UIColor.gray.withAlphaComponent(0.3).setStroke()
        path.stroke()
    }
    
    func drawVerticalLines() {
        let path = UIBezierPath()
        let mins = Int(numberOfPages * 5)
        let step = width / CGFloat(mins)
        for i in 0 ..< mins {
            path.move(to: CGPoint(x: CGFloat(i) * step, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(i) * step, y: height - bottomPadding / 2.0))
        }
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = axisLineWidth
        layer.strokeColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.layer.addSublayer(layer)
        
    }
    
    func drawXAxisLabels() {
        let mins = Int(numberOfPages * 5)
        let step = width / CGFloat(mins)
        for i in 0 ..< mins {
            let axisText = NSAttributedString(string: "\(i)", attributes: axisTextAttribute)
            axisText.draw(at: CGPoint(x: CGFloat(i) * step + 2, y: height - bottomPadding + 2))
        }
    }

}
