//
//  UdacityClient.swift
//  On The Map
//
//  Created by Tobias Helmrich on 23.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // MARK: - Properties
    
    // Shared session
    let session = URLSession.shared
    
    // MARK: - Helper functions
    func udacityUrlWith(pathExtension: String) -> URL {
        // Create a URLComponents object and set its properties
        var urlComponents = URLComponents()
        urlComponents.scheme = Constant.scheme.rawValue
        urlComponents.host = Constant.host.rawValue
        urlComponents.path = "\(Constant.apiPath.rawValue)/\(Method.session.rawValue)"
        
        // Return the resulting URL by accessing the URLComponents object's url property
        return urlComponents.url!
    }

}
