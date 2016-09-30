//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Tobias Helmrich on 23.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension UdacityClient {
    // MARK: - URL
    enum Constant: String {
        case scheme = "https"
        case host = "www.udacity.com"
        case apiPath = "/api"
        case signUpPageUrlString = "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com"
    }
    
    // MARK: - Methods
    enum Method: String {
        case session
    }
    
    enum JSONResponseKey: String {
        case account, key, session, id
    }
}
