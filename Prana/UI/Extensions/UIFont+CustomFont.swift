//
//  UIFont+CustomFont.swift
//  Prana
//
//  Created by Shine Man on 1/8/20.
//  Copyright © 2020 Prana. All rights reserved.
//

import UIKit

extension UIFont {
    class func regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func medium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func bold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func semiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func light(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
