//
//  ClientError.swift
//  On The Map
//
//  Created by Tobias Helmrich on 25.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum ClientError: Error {
    case parsingError(String)
    case unsuccessfulStatusCode(String)
    case noDataReturned(String)
    case noResultReceived(String)
    case serializationError(String)
    case keyNotFound(String)
    case missingAccountKey(String)
    case noStudentLocationFound(String)
}
