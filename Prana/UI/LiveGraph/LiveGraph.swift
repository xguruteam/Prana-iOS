//
//  LiveGraph.swift
//  Prana
//
//  Created by Luccas on 3/19/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class LiveGraph: UIView {
    
    var objLive: Live? {
        didSet {
            objLive?.addDelegate(self)
        }
    }
    
    private var width: CGFloat {
        return bounds.width
    }
    
    private var height: CGFloat {
        return bounds.height
    }
    
    let lineWith: CGFloat = 2.0
    
    @IBInspectable var lineColor: UIColor = UIColor.black
    @IBInspectable var topLineColor: UIColor = UIColor.red
    @IBInspectable var bottomLineColor: UIColor = UIColor.blue
    @IBInspectable var endLineColor: UIColor = UIColor.yellow
    
    deinit {
        objLive?.removeDelegate(self)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard let live = objLive else {
            return
        }
        
        if live.count <= 1 {
            return
        }
        
        let path = UIBezierPath()
        lineColor.setStroke()
        path.lineWidth = lineWith
        
        let xStep = (width - 50) / CGFloat(live.totalPoints - 1)
        
        path.move(to: CGPoint(x: 0, y: scale(live.graphYSeries[0])))
        for i: Int in 1 ... live.count {
            path.addLine(to: CGPoint(x: CGFloat(i) * xStep, y: scale(live.graphYSeries[i])))
        }
        
        path.stroke()
        
        if (live.isDrawTop) {
            let topPath = UIBezierPath()
            topLineColor.setStroke()
            
            topPath.move(to: CGPoint(x: 0, y: scale(live.topReversalY)))
            topPath.addLine(to: CGPoint(x: width, y: scale(live.topReversalY)))
            topPath.stroke()
        }
        
        if (live.isDrawBottom) {
            let bottomPath = UIBezierPath()
            bottomLineColor.setStroke()
            
            bottomPath.move(to: CGPoint(x: 0, y: scale(live.bottomReversalY)))
            bottomPath.addLine(to: CGPoint(x: width, y: scale(live.bottomReversalY)))
            bottomPath.stroke()
        }
        
        if (live.breathEnding == 1) {
            let endPath = UIBezierPath()
            endLineColor.setStroke()
            
            endPath.move(to: CGPoint(x: 0, y: scale(live.endBreathY)))
            endPath.addLine(to: CGPoint(x: width, y: scale(live.endBreathY)))
            endPath.stroke()
        }
    }
    
    func scale(_ value: Double) -> CGFloat {
        return CGFloat(value / Double(Live.Constants.maxYOfBreathing) * Double(height))
    }

}

extension LiveGraph: LiveDelegate {
    func liveDidUprightSet() {
        
    }
    
    func liveNewBreathingCalculated() {
        setNeedsDisplay()
    }
    
    func liveNewPostureCalculated() {
    }
    
    func liveNewRespRateCaclculated() {
    }
    
    
}
