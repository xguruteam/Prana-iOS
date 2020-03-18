//
//  UIButton_Gradient.swift
//  Prana
//
//  Created by Shine Man on 12/29/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
 
    func applyButtonGradient(colors: [UIColor], points: [NSNumber]) {        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.withAlphaComponent(1.0).cgColor }
        gradient.locations = points
        
//        self.layer.addSublayer(gradient)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

@IBDesignable extension UIView {
    
    /// Should the corner be as circle
    @IBInspectable public var circleCorner: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == cornerRadius
        }
        set {
            cornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : cornerRadius
        }
    }

    /// Shadow path of view; also inspectable from Storyboard.
    @IBInspectable public var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set {
            layer.shadowPath = newValue
        }
    }
    
    /// Should shadow rasterize of view; also inspectable from Storyboard.
    /// cache the rendered shadow so that it doesn't need to be redrawn
    @IBInspectable public var shadowShouldRasterize: Bool {
        get {
            return layer.shouldRasterize
        }
        set {
            layer.shouldRasterize = newValue
        }
    }
    
    /// Should shadow rasterize of view; also inspectable from Storyboard.
    /// cache the rendered shadow so that it doesn't need to be redrawn
    @IBInspectable public var shadowRasterizationScale: CGFloat {
        get {
            return layer.rasterizationScale
        }
        set {
            layer.rasterizationScale = newValue
        }
    }
    
    /// Corner radius of view; also inspectable from Storyboard.
    @IBInspectable public var maskToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
}


// MARK: - Properties

public extension UIView {
    
    /// Size of view.
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    
    /// Width of view.
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    /// Height of view.
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
}

extension UIView {
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.flatMap { $0.superview(of: T.self) }
    }
    
}


// MARK: - Methods

public extension UIView {
    
    typealias Configuration = (UIView) -> Swift.Void
    
    func config(configurate: Configuration?) {
        configurate?(self)
    }
    
    /// Set some or all corners radiuses of view.
    ///
    /// - Parameters:
    ///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
    ///   - radius: radius for selected corners.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

extension UIView {
    
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        } else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        return nil
    }
    
    /// This is the function to get subViews of a view of a particular type
    /// https://stackoverflow.com/a/45297466/5321670
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /// This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T
    /// https://stackoverflow.com/a/45297466/5321670
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

