//
//  PostureBar.swift
//  Prana
//
//  Created by Guru on 6/25/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PostureBar: UIView {
    
    
    var slouches: [SlouchRecord]!
    var duration: Int!

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        for slouch in slouches {
            let unit = CGFloat(width) / CGFloat(duration)
            let x = CGFloat(slouch.timeStamp) * unit
            let w = CGFloat(slouch.duration) * unit
            let path = UIBezierPath(rect: CGRect(x: x, y: 0, width: w, height: height))
            UIColor(hexString: "#ff0000").setFill()
            path.fill()
        }
    }

}
