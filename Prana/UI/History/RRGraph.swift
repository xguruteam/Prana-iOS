//
//  RRGraph.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class RRGraph: UIView {

    var breaths: [BreathRecord]!
    var duration: Int! {
        didSet {
            mins = duration / 60
        }
    }
    
    var mins: Int!
    
    let marginL: CGFloat = 20
    let marginT: CGFloat = 20
    let marginB: CGFloat = 20
    let marginR: CGFloat = 20
    
    var cw: CGFloat {
        return width - marginL - marginR
    }
    
    var ch: CGFloat {
        return height - marginT - marginB
    }
    
    override func draw(_ rect: CGRect) {
        let coordinate = UIBezierPath()
        
        coordinate.move(to: CGPoint(x: cx(0), y: cy(ch)))
        coordinate.addLine(to: CGPoint(x: cx(0), y: cy(0)))
        coordinate.addLine(to: CGPoint(x: cx(cw), y: cy(0)))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = coordinate.cgPath
        shapeLayer.strokeColor = UIColor(hexString: "#c0c3c9").cgColor
        shapeLayer.lineWidth = 3
        layer.addSublayer(shapeLayer)
//        UIColor(hexString: "#c0c3c9").setStroke()
//        coordinate.stroke(with: CGBlendMode(rawValue: 3)!, alpha: 0.4)
        
        for i in 0...mins {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key : Any] = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont(name: "Quicksand-Bold", size: 13),
                .foregroundColor: UIColor(hexString: "#79859f")
            ]
            let attributedString = NSAttributedString(string: "\(i)", attributes: attributes)
            let stringRect = CGRect(x: cx(CGFloat(i) * (cw / CGFloat(mins)) - 10), y: cy(0), width: 20, height: 20)
            attributedString.draw(in: stringRect)
        }
    }
    
    func cx(_ point: CGFloat) -> CGFloat {
        return point + marginL
    }
    
    func cy(_ point: CGFloat) -> CGFloat {
        return height - marginB - point
    }
}
