//
//  DataSourceError.swift
//  On The Map
//
//  Created by Tobias Helmrich on 14.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum DataSourceError: String {
    case studentLocationsRequestFailed = "Couldn't receive student locations"
    case noStudentLocations = "No student locations available"
}
