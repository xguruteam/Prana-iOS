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
    
//    private var width: CGFloat {
//        return bounds.width
//    }
//    
//    private var height: CGFloat {
//        return bounds.height
//    }
    
    let lineWith: CGFloat = 4.0
    
    @IBInspectable var lineColor: UIColor = UIColor.colorFromHex(hexString: "#5EB839")
    @IBInspectable var topLineColor: UIColor = UIColor.colorFromHex(hexString: "#FA9797")
    @IBInspectable var bottomLineColor: UIColor = UIColor.colorFromHex(hexString: "#A3C53C")
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
        
        let yPos = live.yPos
        
        let count = live.count
        
        if count <= 1 {
            return
        }
        
        if count > (live.totalPoints-1) {
            return
        }
        
        let path = UIBezierPath()
        lineColor.setStroke()
        path.lineWidth = lineWith
        
        let xStep = (width - 50) / CGFloat(live.totalPoints - 1)
        
        path.move(to: CGPoint(x: 0, y: scale(yPos[0])))
        for i: Int in 1 ... count {
            let y = yPos[i]
//            if y > live.yStartPos {
//                break
//            }
            path.addLine(to: CGPoint(x: CGFloat(i) * xStep, y: scale(y)))
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
    func liveProcess(sensorData: [Double]) {
        
    }
    
    func liveDebug(para1: String, para2: String, para3: String, para4: String) {
        
    }
    
    func liveDidUprightSet() {
        
    }
    
    func liveNewBreathingCalculated() {
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func liveNewPostureCalculated() {
    }
    
    func liveNewRespRateCaclculated() {
    }
    
    
}
