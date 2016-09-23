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
    }
    
    // MARK: - Methods
    enum Method: String {
        case session
    }
}
