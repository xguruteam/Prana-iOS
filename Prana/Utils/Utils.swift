//
//  Utils.swift
//  Prana
//
//  Created by Luccas on 2/28/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import SwiftyJSON

class Utils {
    static func isValidEmail(str:String) -> Bool {
        if str == "" {
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: str)
    }
    
    static func isValidPassword(str:String) -> Bool {
        if str.count < 4 || str.count > 20 {
            return false
        }
        
        return true
    }
    
    static func isValidBirthdate(str:String) -> Bool {
        if (str == "") {
            return false
        }
        
        return true
    }
    
    static func isValidGender(str:String) -> Bool {
        if (str == "") {
            return false
        }
        
        return true
    }
    
    static func getStoryboardWithIdentifier(name: String = "Main", identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller;
    }
}
