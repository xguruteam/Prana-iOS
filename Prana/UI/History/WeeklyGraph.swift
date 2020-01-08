//
//  WeeklyGraph.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class WeeklyGraph: UIView {

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
    
    enum GraphType {
        case stack
        case bar
    }
    var type: GraphType = .stack
    
    var stackData: [(Int, Int)] = [] {
        didSet {
            var (max, _) = stackData.max { $0.0 < $1.0 }!
            if max < 60 {
                max = 60
            }
            self.max = CGFloat(max)
        }
    }
    var barData: [Double] = [] {
        didSet {
            let max = barData.max()!
            self.max = CGFloat(max == 0 ? 20 : max)
        }
    }
    
    var max: CGFloat = 0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if type == .stack && stackData.count <= 0 {
            super.draw(rect)
            return
        }
        
        if type == .bar && barData.count <= 0 {
            super.draw(rect)
            return
        }
        let uw = width / 8
//        let uh = CGFloat(max)
        let th: CGFloat = 20
        let bw: CGFloat = 20
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.bold(ofSize: 13),
            .foregroundColor: UIColor(hexString: "#79859f")
        ]
        
        var attributedString: NSAttributedString!
        if type == .stack {
            attributedString = NSAttributedString(string: "\(Int(max / 60))", attributes: attributes)
        } else {
            attributedString = NSAttributedString(string: "\(roundFloat(Float(max), point: 0))", attributes: attributes)
        }
        
        var stringRect = CGRect(x: 0, y: 0, width: uw, height: th)
        attributedString.draw(in: stringRect)
        
        if type == .stack {
            let avg = max / 2 / 60
            
            if avg > 0 {
                attributedString = NSAttributedString(string: "\(roundFloat(Float(avg), point: 1))", attributes: attributes)
                stringRect = CGRect(x: 0, y: height / 2 - th / 2, width: uw, height: th)
                attributedString.draw(in: stringRect)
            }
            
        } else {
            let avg = Float(max / 2)
            
            if avg > 0 {
                attributedString = NSAttributedString(string: "\(roundFloat(Float(avg), point: 0))", attributes: attributes)
                stringRect = CGRect(x: 0, y: height / 2 - th / 2, width: uw, height: th)
                attributedString.draw(in: stringRect)
            }
        }
        
        attributedString = NSAttributedString(string: "\(0)", attributes: attributes)
        stringRect = CGRect(x: 0, y: height - th, width: uw, height: th)
        attributedString.draw(in: stringRect)
        
        let letters = ["M", "T", "W", "T", "F", "S", "S"]
        for i in 0..<letters.count {
            if type == .stack {
                let (total, part) = stackData[i]
                let totalR = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th - (height - th) * CGFloat(total) / CGFloat(max), width: bw, height: (height - th) * CGFloat(total) / CGFloat(max))
                let totalP = UIBezierPath(rect: totalR)
                UIColor(hexString: "#c0c3c9").setStroke()
                totalP.stroke()
                
                let partR = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th - (height - th) * CGFloat(part) / CGFloat(max), width: bw, height: (height - th) * CGFloat(part) / CGFloat(max))
                let partP = UIBezierPath(rect: partR)
                color.setFill()
                partP.fill()
                
            } else {
                let total = barData[i]
                let totalR = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th - (height - th) * CGFloat(total) / CGFloat(max), width: bw, height: (height - th) * CGFloat(total) / CGFloat(max))
                let totalP = UIBezierPath(rect: totalR)
                color.setFill()
                totalP.fill()
            }
            
            attributedString = NSAttributedString(string: letters[i], attributes: attributes)
            stringRect = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th, width: bw, height: th)
            attributedString.draw(in: stringRect)
        }
        
    }
    

}
