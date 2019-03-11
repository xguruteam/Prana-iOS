//
//  PostureIndicator.swift
//  Prana
//
//  Created by Luccas on 3/9/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

@IBDesignable
class PostureIndicator: UIView {
    
    var breathingGraphView: BreathingGraph? = nil
    
    var xPos:Int = 3
    
    @IBInspectable var horLineColor: UIColor = UIColor.lightGray
    @IBInspectable var verLineColor: UIColor = UIColor.darkGray
    @IBInspectable var indicatorLineColor: UIColor = UIColor.orange
    @IBInspectable var uprightLineColor: UIColor = UIColor.green
    @IBInspectable var slouchLineColor: UIColor = UIColor.red
    
    open func setBreathingGraphView(view: BreathingGraph) {
        breathingGraphView = view
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override func draw(_ rect: CGRect) {
        
        horLineColor.setFill()
        let horRectPath:UIBezierPath = UIBezierPath(rect: CGRect(x: 3, y: 16, width: Int(width-6), height: 16))
        horRectPath.fill()
        
        let horStep:Double = Double(width-6) / 7
        for i:Int in 0..<7 {
            horLineColor.setStroke()
            let grayVPath = UIBezierPath()
            grayVPath.lineWidth = 3
            grayVPath.move(to: CGPoint(x: Int((Double(i) + 0.5)*horStep + 3), y: 12))
            grayVPath.addLine(to: CGPoint(x: CGFloat(Int((Double(i) + 0.5)*horStep) + 3), y: CGFloat(36)))
            grayVPath.stroke()
            
            verLineColor.setStroke()
            let blackVPath = UIBezierPath()
            blackVPath.lineWidth = 3
            blackVPath.move(to: CGPoint(x: Double(i)*horStep + 3, y: 8))
            blackVPath.addLine(to: CGPoint(x: CGFloat(Double(i)*horStep + 3), y: CGFloat(40)))
            blackVPath.stroke()
        }
        
        verLineColor.setStroke()
        let blackVPath = UIBezierPath()
        blackVPath.lineWidth = 3
        blackVPath.move(to: CGPoint(x: Double(7)*horStep + 3, y: 8))
        blackVPath.addLine(to: CGPoint(x: CGFloat(Double(7)*horStep + 3), y: CGFloat(40)))
        blackVPath.stroke()
        
        slouchLineColor.setStroke()
        let slouchPath = UIBezierPath()
        slouchPath.lineWidth = 4
        slouchPath.move(to: CGPoint(x: 3, y: 48))
        slouchPath.addLine(to: CGPoint(x: Double(4)*horStep + 3, y: 48))
        slouchPath.stroke()
        
        uprightLineColor.setStroke()
        let uprightPath = UIBezierPath()
        uprightPath.lineWidth = 4
        uprightPath.move(to: CGPoint(x: Double(4)*horStep + 3, y: 48))
        uprightPath.addLine(to: CGPoint(x: Double(7)*horStep + 3, y: 48))
        uprightPath.stroke()
        
        indicatorLineColor.setStroke()
        let indicatorPath = UIBezierPath()
        indicatorPath.lineWidth = 3
        indicatorPath.move(to: CGPoint(x: xPos, y: 8))
        indicatorPath.addLine(to: CGPoint(x: CGFloat(xPos), y: CGFloat(40)))
        indicatorPath.stroke()
    }
    
    private var width: CGFloat {
        return bounds.width
    }
    
    private var height: CGFloat {
        return bounds.height
    }
    
    open func displayPostureIndicator(x: Int) {
        print("x \(x)")
        xPos = x
        
        setNeedsDisplay()
    }
}
