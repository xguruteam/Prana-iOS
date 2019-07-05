//
//  User.swift
//  Prana
//
//  Created by Luccas on 7/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: String
    var token: String
    
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var birthDay: Date
    var gender: String // male, female
    
    init(data: [String: Any]) {
        id = "id"
        token = data["access_token"] as! String
        
        firstName = "First Name"
        lastName = "Last Name"
        email = "email"
        password = "password"
        birthDay = Date()
        gender = "male"
    }
}
