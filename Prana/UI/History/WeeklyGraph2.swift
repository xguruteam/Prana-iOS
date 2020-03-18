//
//  WeeklyGraph2.swift
//  Prana
//
//  Created by Guru on 6/26/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class WeeklyGraph2: UIView {

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
    
//    let letters = ["M", "T", "W", "T", "F", "S", "S"]
    let letters = Calendar.current.veryShortWeekdaySymbols

    var color: UIColor = .black
    
    var barData: [(Float, String?)] = []
    
    var max: CGFloat = 0
    
    var unit: MeasurementUnit = .inch
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if barData.count <= 0 {
            super.draw(rect)
            return
        }
        
        let m = barData.max { $0.0 < $1.0 }!
        if m.0 <= 0 { self.max = 50 } else { self.max = CGFloat(m.0) }
        
        let uw = width / 8
        let hc: CGFloat = 6
        let dh: CGFloat = 30
        
        let uh = (height - dh) / hc
        
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
        var stringRect: CGRect!
        
        for i in 0..<Int(hc) {
            if unit == .inch {
                attributedString = NSAttributedString(string: "\(roundFloat(Float(max) / Float(hc - 1) * Float(i), point: 2))", attributes: attributes)
            } else {
                attributedString = NSAttributedString(string: "\(roundFloat(Float(max) / Float(hc - 1) * Float(i) * 2.54, point: 2))", attributes: attributes)
            }
            stringRect = CGRect(x: 0, y: height - uh * CGFloat(i) - th, width: uw, height: th)
            attributedString.draw(in: stringRect)
        }
        
        for i in 0..<letters.count {
            let (total, diary) = barData[i]
            let totalR = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th - (height - th - dh) * CGFloat(total) / CGFloat(max), width: bw, height: (height - th - dh) * CGFloat(total) / CGFloat(max))
            let totalP = UIBezierPath(rect: totalR)
            color.setFill()
            totalP.fill()
            
            attributedString = NSAttributedString(string: letters[i], attributes: attributes)
            stringRect = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th, width: bw, height: th)
            attributedString.draw(in: stringRect)
            
            if total > 0 {
                attributedString = NSAttributedString(string: "\(roundFloat(unit == .inch ? total : (total * 2.54), point: 2))", attributes: attributes)
                stringRect = CGRect(x: uw + CGFloat(i) * uw, y: height - th - (height - th - dh) * CGFloat(total) / CGFloat(max) - th + 5, width: uw, height: th)
                attributedString.draw(in: stringRect)
            }
            
            if diary != nil {
                attributedString = NSAttributedString(string: "D", attributes: attributes)
                stringRect = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: height - th - (height - th - dh) * CGFloat(total) / CGFloat(max) - dh, width: bw, height: th)
                attributedString.draw(in: stringRect)
            }
        }
        
    }
    
    var diaryClickHandler: ((Int, String) -> ())?
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        
        let m = barData.max { $0.0 < $1.0 }!
        if m.0 <= 0 { self.max = 50 } else { self.max = CGFloat(m.0) }
        
        let uw = width / 8
        let hc: CGFloat = 6
        let dh: CGFloat = 30
        
//        let uh = (height - dh) / hc
        
//        let th: CGFloat = 20
        let bw: CGFloat = 20
        
        for i in 0..<letters.count {
            let totalR = CGRect(x: uw + CGFloat(i) * uw + uw / 2.0 - bw / 2.0, y: 0, width: bw, height: height)
            if totalR.contains(location) {
                if let note = barData[i].1 {
                    print("----->diary")
                    diaryClickHandler?(i, note)
                }
                return
            }
        }
    }
}
