//
//  LiveGraph2.swift
//  Prana
//
//  Created by Guru on 9/28/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class LiveGraph: UIView {

    var objLive: Live? {
        willSet{
            objLive?.removeDelegate(self)
            newValue?.addDelegate(self)
            data = Array(repeating: 500, count: LiveGraph.max)
            bottomReversalY = 5000
            endBreathY = 5000
        }
    }
    
    deinit {
        objLive?.removeDelegate(self)
    }
    
    let lineWith: CGFloat = 4.0
    
    var lineColor: UIColor = UIColor.colorFromHex(hexString: "#2bb7b8")
    var topLineColor: UIColor = UIColor.colorFromHex(hexString: "#FA9797")
    var bottomLineColor: UIColor = UIColor.blue
    var endLineColor: UIColor = UIColor.colorFromHex(hexString: "#6fc13b")
    
    static let max = 280
    var data: [Double] = Array(repeating: 500, count: max)
    var bottomReversalY: Double = 5000
    var endBreathY: Double = 5000
    
    override func draw(_ rect: CGRect) {
        
        guard let _ = objLive else {
            return
        }
        
        let path = UIBezierPath()
        
        lineColor.setStroke()
        path.lineWidth = lineWith
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        let xStep = (width - 50) / CGFloat(LiveGraph.max - 1)
        
        path.move(to: CGPoint(x: 0, y: scale(data[0])))
        for i: Int in 1 ..< LiveGraph.max {
            path.addLine(to: CGPoint(x: CGFloat(i) * xStep, y: scale(data[i])))
        }
        
        path.stroke()
        
        let bottomPath = UIBezierPath()
        bottomLineColor.setStroke()
        
        bottomPath.move(to: CGPoint(x: 0, y: scale(bottomReversalY)))
        bottomPath.addLine(to: CGPoint(x: width, y: scale(bottomReversalY)))
        bottomPath.stroke()

        let endPath = UIBezierPath()
        endLineColor.setStroke()
        
        endPath.move(to: CGPoint(x: 0, y: scale(endBreathY)))
        endPath.addLine(to: CGPoint(x: width, y: scale(endBreathY)))
        endPath.stroke()
    }
    
    func scale(_ value: Double) -> CGFloat {
        return CGFloat(value / objLive!.yStartPos * Double(height)) - 5.0
    }

}

extension LiveGraph: LiveDelegate {
    func liveNew(graphY: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.data.append(graphY)
            self?.data.removeFirst()
            self?.setNeedsDisplay()
        }
    }
    
    func liveNew(endBreathLineY: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.endBreathY = endBreathLineY
            self?.setNeedsDisplay()
        }
    }
    
    func liveNew(bottomReversalLineY: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.bottomReversalY = bottomReversalLineY
            self?.setNeedsDisplay()
        }
    }
}
