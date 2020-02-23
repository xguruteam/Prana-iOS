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
    var numberOfPages: Int!

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let unit = CGFloat(width) / CGFloat(numberOfPages * 5 * 60)
        let bpath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(duration) * unit, height: height))
        UIColor(hexString: "#5eb839").setFill()
        bpath.fill()

        for slouch in slouches {
            let x = CGFloat(slouch.timeStamp) * unit
            let w = CGFloat(slouch.duration) * unit
            let path = UIBezierPath(rect: CGRect(x: x, y: 0, width: w, height: height))
            UIColor(hexString: "#ff0000").setFill()
            path.fill()
        }
    }

}
