//
//  PostureBar2.swift
//  Prana
//
//  Created by Guru on 11/5/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PostureBar2: UIView {

    var session: TrainingSession?
    
    var duration: CGFloat {
        return CGFloat(session?.duration ?? 0)
    }
    
    var numberOfPages: Int = 0
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let postures = session?.judgedPosture else {
            return
        }
        
        let unit = CGFloat(width) / CGFloat(numberOfPages * 5 * 60)
        let bpath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(duration) * unit, height: height))
        UIColor(hexString: "#5eb839").setFill()
        bpath.fill()
        
        for i in 0 ..< postures.count {
            var slouchDuration = 0
            
            let posture = postures[i]
            guard posture.isGood == 0 else { continue }
            
            if i < postures.count - 1 {
                let next = postures[i + 1]
                slouchDuration = next.time - posture.time
            } else {
                slouchDuration = Int(duration) - posture.time
            }
            
            let x = CGFloat(posture.time) * unit
            let w = CGFloat(slouchDuration) * unit
            let path = UIBezierPath(rect: CGRect(x: x, y: 0, width: w, height: height))
            UIColor(hexString: "#ff0000").setFill()
            path.fill()
        }
        
    }
    

}
