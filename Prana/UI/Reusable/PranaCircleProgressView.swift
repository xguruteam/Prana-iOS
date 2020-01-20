//
//  PranaCircleProgressView.swift
//  CircleTest
//
//  Created by Luccas on 4/30/19.
//  Copyright © 2019 Luccas. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PranaCircleProgressView: UIView {
    @IBInspectable var startColor: UIColor = .white { didSet { setNeedsLayout() } }
    @IBInspectable var endColor:   UIColor = .blue  { didSet { setNeedsLayout() } }
    @IBInspectable var lineWidth:  CGFloat = 3      { didSet { setNeedsLayout() } }
    @IBInspectable var progress:  CGFloat = 0      { didSet { setNeedsLayout() } }
    @IBInspectable var circleShadowColor: UIColor = .black { didSet { setNeedsLayout() } }
    
    private let gradientLayer: PranaCircleProgressLayer = {
        let gradientLayer = PranaCircleProgressLayer()
        return gradientLayer
    }()
    
    var shadowLayer: CALayer!
    var ovalLayer: CAShapeLayer!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()        
        updateGradient()
    }
    
    func configure() {
        let ovalLayer = CAShapeLayer()
        var rect = bounds
        rect.origin.x += lineWidth / 2.0
        rect.origin.y += lineWidth / 2.0
        rect.size.width -= lineWidth
        rect.size.height -= lineWidth
        ovalLayer.path = UIBezierPath(ovalIn: rect).cgPath
        ovalLayer.strokeColor = UIColor(hexString: "#F2F2F2").cgColor
        ovalLayer.lineWidth = 2
        ovalLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(ovalLayer)
        
        self.ovalLayer = ovalLayer
        
        
        let shadowLayer = CALayer()
        shadowLayer.shadowColor = circleShadowColor.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: -11)
        shadowLayer.shadowRadius = 6
        shadowLayer.shadowOpacity = 0.28
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        shadowLayer.insertSublayer(gradientLayer, at: 0)
        layer.addSublayer(shadowLayer)
//        layer.addSublayer(gradientLayer)
        
        self.shadowLayer = shadowLayer
    }
    
    func updateGradient() {
        var rect = bounds
        rect.origin.x += lineWidth / 2.0
        rect.origin.y += lineWidth / 2.0
        rect.size.width -= lineWidth
        rect.size.height -= lineWidth
        ovalLayer.path = UIBezierPath(ovalIn: rect).cgPath
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor, endColor].map { $0.cgColor }
        gradientLayer.lineWidth = lineWidth
        gradientLayer.progress = progress
        
        shadowLayer.shadowColor = circleShadowColor.cgColor
    }
    
    func startAnimation() {
        let animation = CABasicAnimation(keyPath: "progress")
        animation.fromValue = 0.0
        animation.toValue = progress
        animation.duration = 0.6
        animation.repeatCount = 0
        animation.autoreverses = false
        animation.isRemovedOnCompletion = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        gradientLayer.add(animation, forKey: "progress")
    }
}

class PranaCircleProgressLayer: CAGradientLayer {
    @objc dynamic var progress: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init() {
        super.init()
        configure()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        let player = layer as! PranaCircleProgressLayer
        self.progress = player.progress
        self.lineWidth = player.lineWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        if #available(iOS 12.0, *) {
            type = .conic
        } else {
            // Fallback on earlier versions
        }
        startPoint = CGPoint(x: 0.5, y: 0.5)
        endPoint = CGPoint(x: 0.5, y: 0)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" { return true }
        return super.needsDisplay(forKey: key)
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -0.5 * .pi, endAngle: 2 * .pi * progress - 0.5 * .pi, clockwise: true)
        let mask = CAShapeLayer()
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = lineWidth
        mask.path = path.cgPath
        mask.lineCap = .round
        self.model().mask = mask
    }
    
}
