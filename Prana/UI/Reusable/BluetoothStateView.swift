//
//  BluetoothStateView.swift
//  Prana
//
//  Created by Guru on 5/23/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class BluetoothStateView: UIImageView {

    
    var isEnabled = true {
        didSet {
            if isEnabled {
                image = UIImage(named: "ic_bluetooth")
            }
            else {
                image = UIImage(named: "ic_bluetooth_gray")
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
