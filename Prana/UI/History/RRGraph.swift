//
//  RRGraph.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class RRGraph: UIView {
    
    var session: TrainingSession?
    
    var maxRR: CGFloat {
        let defaultMaxRR: CGFloat = 16.0
        
        guard let breaths = session?.judgedBreaths else {
            return defaultMaxRR
        }
        
        var max: CGFloat = 0
        breaths.forEach {
            guard let targetRR = $0.target?.rr else { return }
            if CGFloat(targetRR) > max { max = CGFloat(targetRR) }
        }
        
        guard max > 0 else { return defaultMaxRR }
        
        max = CGFloat(Int(max))
        if Int(max) % 2 != 0 {
            max += 1
        }
        return max
    }
    
    var duration: CGFloat {
        let defaultDuration: CGFloat = 300
        guard let session = session else {
            return defaultDuration
        }
        
        var pages = Int(session.duration) / 300
        
        if session.duration > pages * 300 {
            pages += 1
        }
        
        return CGFloat(pages * 300)
    }
    
//    var width: CGFloat {
//        return frame.width
//    }
//
//    var height: CGFloat {
//        return frame.height
//    }
    
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
    
    let rootLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    let yaxisTextAttribute: [NSAttributedString.Key : Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont(name: "Quicksand", size: 12) as Any,
            .foregroundColor: UIColor(hexString: "#000000")
        ]
        return attributes
    }()
    
    let axisLineWidth: CGFloat = 0.5
    let lineWidth: CGFloat = 2
    let mindfulColor = UIColor(hexString: "#5eb839")
    let unmindfulColor = UIColor(hexString: "#ff0000")
    let targetColor = UIColor(hexString: "#0000ff")
    let invalidColor = UIColor(hexString: "#acacac")
    
    var padding: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.addSublayer(rootLayer)
        drawLines()
        drawPoints()
        drawXAxisLabels()
        drawYAxisLabels()
    }
    
    func drawLines() {
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: axisLineWidth, y: height - padding.bottom))
        path.addLine(to: CGPoint(x: width - axisLineWidth, y: height - padding.bottom))
        path.addLine(to: CGPoint(x: width - axisLineWidth, y: axisLineWidth))
        path.addLine(to: CGPoint.zero)
        path.lineWidth = axisLineWidth
        UIColor.gray.withAlphaComponent(0.3).setStroke()
        path.stroke()
//
//        let layer = CAShapeLayer()
//        layer.path = path.cgPath
//        layer.lineWidth = 0.5
//        layer.strokeColor = UIColor.gray.withAlphaComponent(0.3).cgColor
//        self.layer.addSublayer(layer)
        
        drawHorizontalLines()
        drawVerticalLines()
    }
    
    func drawHorizontalLines() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: axisLineWidth, y: padding.top))
        path.addLine(to: CGPoint(x: width - axisLineWidth, y: padding.top))
        path.move(to: CGPoint(x: axisLineWidth, y: padding.top + (height - padding.top - padding.bottom) / 2))
        path.addLine(to: CGPoint(x: width - axisLineWidth, y: padding.top + (height - padding.top - padding.bottom) / 2))
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineDashPattern = [5, 5]
        layer.lineWidth = axisLineWidth
        layer.strokeColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.rootLayer.addSublayer(layer)
        
    }
    
    func drawYAxisLabels() {
        // draw y axis labels
        var textLayer = CATextLayer()
        textLayer.string = "\(Int(maxRR))"
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.font = UIFont(name: "Quicksand", size: 12)
        textLayer.fontSize = 12.0
        textLayer.alignmentMode = CATextLayerAlignmentMode.left
        textLayer.frame = CGRect(x: 2, y: padding.top - 12, width: 30, height: 20.0)
        textLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(textLayer)
        
        textLayer = CATextLayer()
        textLayer.string = "\(Int(maxRR / 2))"
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.font = UIFont(name: "Quicksand", size: 12)
        textLayer.fontSize = 12.0
        textLayer.alignmentMode = CATextLayerAlignmentMode.left
        textLayer.frame = CGRect(x: 2, y: padding.top + (height - padding.top - padding.bottom) / 2 - 12, width: 30, height: 20.0)
        textLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(textLayer)
        
//        let maxText = NSAttributedString(string: "\(Int(maxRR))", attributes: yaxisTextAttribute)
//        maxText.draw(at: CGPoint(x: 2, y: padding.top - 12))
        
//        let halfText = NSAttributedString(string: "\(Int(maxRR / 2))", attributes: yaxisTextAttribute)
//        halfText.draw(at: CGPoint(x: 2, y: padding.top + (height - padding.top - padding.bottom) / 2 - 12))
        
        let zeroText = NSAttributedString(string: "0", attributes: axisTextAttribute)
        zeroText.draw(at: CGPoint(x: 2, y: height - padding.bottom + 2))
    }
    
    func drawVerticalLines() {
        let path = UIBezierPath()
        let mins = Int(duration / 60)
        let step = width / CGFloat(mins)
        for i in 1 ..< mins {
            path.move(to: CGPoint(x: CGFloat(i) * step, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(i) * step, y: height - padding.bottom / 2.0))
        }
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = axisLineWidth
        layer.strokeColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.rootLayer.addSublayer(layer)
        
    }
    
    func drawXAxisLabels() {
        let mins = Int(duration / 60)
        let step = width / CGFloat(mins)
        for i in 1 ..< mins {
            let axisText = NSAttributedString(string: "\(i)", attributes: axisTextAttribute)
            axisText.draw(at: CGPoint(x: CGFloat(i) * step + 2, y: height - padding.bottom + 2))
        }
    }
    
    func drawPoints() {
        guard let breaths = session?.judgedBreaths else {
            return
        }
        
        var lastCoreBreath: CoreBreath? = nil
        var lastTargetBreath: CoreBreath? = nil
        
        for breath in breaths {
            // for target
            let targetPath = UIBezierPath()
            let targetDotPath = UIBezierPath()
            
            if let target = breath.target {
                if let lastTarget = lastTargetBreath {
                    targetPath.move(to: transform(coreBreath: lastTarget))
                } else{
                    targetPath.move(to: transform(coreBreath: target))
                }
                
                targetPath.addLine(to: transform(coreBreath: target))
                
                targetDotPath.move(to: transform(coreBreath: target))
                targetDotPath.addLine(to: transform(coreBreath: target))
                
                lastTargetBreath = target
                
                let targetLayer = CAShapeLayer()
                targetLayer.path = targetPath.cgPath
                targetLayer.lineWidth = lineWidth
                targetLayer.fillColor = nil
                
                let targetDotLayer = CAShapeLayer()
                targetDotLayer.path = targetDotPath.cgPath
                targetDotLayer.lineWidth = lineWidth * 2
                targetDotLayer.lineCap = .round
                targetDotLayer.lineJoin = .round
                targetDotLayer.fillColor = nil
                
                targetLayer.strokeColor = targetColor.cgColor
                targetDotLayer.strokeColor = targetColor.cgColor

                
                rootLayer.addSublayer(targetLayer)
                rootLayer.addSublayer(targetDotLayer)
            }

            let livePath = UIBezierPath()
            let liveDotPath = UIBezierPath()
            let areaPath = UIBezierPath()
            
            if let lastCore = lastCoreBreath {
                livePath.move(to: transform(coreBreath: lastCore))
                areaPath.move(to: transform(coreBreath: CoreBreath(it: lastCore.it, rr: 0)))
                areaPath.addLine(to: transform(coreBreath: lastCore))
            }
            
            for core in breath.actuals {
                if let _ = lastCoreBreath {
                    livePath.addLine(to: transform(coreBreath: core))
                    areaPath.addLine(to: transform(coreBreath: core))
                } else {
                    livePath.move(to: transform(coreBreath: core))
                    areaPath.move(to: transform(coreBreath: CoreBreath(it: core.it, rr: 0)))
                    areaPath.addLine(to: transform(coreBreath: core))
                }
                lastCoreBreath = core
                liveDotPath.move(to: transform(coreBreath: core))
                liveDotPath.addLine(to: transform(coreBreath: core))
            }
            
            if let lastCore = lastCoreBreath {
                areaPath.addLine(to: transform(coreBreath: CoreBreath(it: lastCore.it, rr: 0)))
            }
            
            let liveLayer = CAShapeLayer()
            liveLayer.path = livePath.cgPath
            liveLayer.lineWidth = lineWidth
            liveLayer.fillColor = nil
            
            let liveDotLayer = CAShapeLayer()
            liveDotLayer.path = liveDotPath.cgPath
            liveDotLayer.lineWidth = lineWidth * 2
            liveDotLayer.lineCap = .round
            liveDotLayer.lineJoin = .round
            liveDotLayer.fillColor = nil
            
            let areaLayer = CAShapeLayer()
            areaLayer.path = areaPath.cgPath
            areaLayer.strokeColor = nil


            switch breath.breathStatus {
            case 0:
                liveLayer.strokeColor = unmindfulColor.cgColor
                liveDotLayer.strokeColor = unmindfulColor.cgColor
                areaLayer.fillColor = unmindfulColor.withAlphaComponent(0.1).cgColor
            case 1:
                liveLayer.strokeColor = mindfulColor.cgColor
                liveDotLayer.strokeColor = mindfulColor.cgColor
                areaLayer.fillColor = mindfulColor.withAlphaComponent(0.1).cgColor
            default:
                liveLayer.strokeColor = invalidColor.cgColor
                liveDotLayer.strokeColor = invalidColor.cgColor
                areaLayer.fillColor = invalidColor.withAlphaComponent(0.1).cgColor
            }
            
            rootLayer.addSublayer(areaLayer)
            rootLayer.addSublayer(liveLayer)
            rootLayer.addSublayer(liveDotLayer)
        }
    }
    
    func transform(coreBreath: CoreBreath) -> CGPoint {
        let x = CGFloat(coreBreath.it) / duration * width
        let rr = CGFloat(coreBreath.rr)
        let maxRange = height - padding.top - padding.bottom
        var y = maxRange * (1.0 - rr / maxRR) + padding.top
        if y > height - padding.bottom { y = height - padding.bottom}
        if y < lineWidth { y = lineWidth }
        return CGPoint(x: x, y: y)
    }
}
