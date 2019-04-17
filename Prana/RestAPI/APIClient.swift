//
//  APIClient.swift
//  Prana
//
//  Created by Luccas on 2/28/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
//    static var BaseURL = "http://10.70.10.11:8000/api/"
    static var BaseURL = "http://202.173.118.30/api/"
    
    static let sessionManager: SessionManager = {
        return Alamofire.SessionManager(
            serverTrustPolicyManager: UnsafeServerTrustPolicyManager()
        )
    }()
    
    private class UnsafeServerTrustPolicyManager: ServerTrustPolicyManager {
        init() {
            super.init(policies: [:])
        }
        
        override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return .disableEvaluation
        }
    }
}
