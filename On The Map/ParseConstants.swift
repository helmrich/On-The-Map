//
//  ParseConstants.swift
//  On The Map
//
//  Created by Tobias Helmrich on 24.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension ParseClient {
    enum Constant: String {
        case scheme = "https"
        case host = "parse.udacity.com"
        case studentLocationApiPath = "/parse/classes/StudentLocation"
    }
    
    enum HTTPHeaderFieldName: String {
        case applicationId = "X-Parse-Application-Id"
        case restApiKey = "X-Parse-REST-API-Key"
        case contentType = "Content-Type"
    }
    
    enum HTTPHeaderFieldValue: String {
        case applicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        case restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        case contentType = "application/json"
    }
    
    enum ParameterKey: String {
        case whereKey = "where"
        case limit, skip, order
    }
    
    enum ParameterValue: String {
        case uniqueKey = "{\"uniqueKey\":\"{uniqueKey}\"}"
        case updatedAt, createdAt
    }
    
    enum ParameterPlaceholder: String {
        case uniqueKey
    }
    
    enum JSONResponseKey: String {
        case createdAt, firstName, lastName, latitude, longitude, mapString, mediaURL, objectId, uniqueKey, updatedAt, results
    }
}
