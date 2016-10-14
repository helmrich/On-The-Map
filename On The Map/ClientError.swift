//
//  ClientError.swift
//  On The Map
//
//  Created by Tobias Helmrich on 25.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum ClientError: String {
    case parsingError = "Parsing Error"
    case unsuccessfulStatusCode = "Unsuccessful status code"
    case noDataReceived = "Couldn't receive data"
    case noResultReceived = "Didn't receive result"
    case deserializationError = "Couldn't deserialize data"
    case keyNotFound = "Couldn't find key"
    case missingAccountKey = "No account key provided"
    case noStudentLocationFound = "Couldn't find student location"
}
