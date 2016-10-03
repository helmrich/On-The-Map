//
//  StudentLocation.swift
//  On The Map
//
//  Created by Tobias Helmrich on 24.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct StudentLocation {
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaUrlString: String
    let latitude: Double
    let longitude: Double
    
    init?(fromDictionary dictionary: [String:Any]) {
        if let firstName = dictionary[ParseClient.JSONResponseKey.firstName.rawValue] as? String,
        let lastName = dictionary[ParseClient.JSONResponseKey.lastName.rawValue] as? String,
        let latitude = dictionary[ParseClient.JSONResponseKey.latitude.rawValue] as? Double,
        let longitude = dictionary[ParseClient.JSONResponseKey.longitude.rawValue] as? Double,
        let mapString = dictionary[ParseClient.JSONResponseKey.mapString.rawValue] as? String,
        let mediaUrlString = dictionary[ParseClient.JSONResponseKey.mediaURL.rawValue] as? String {
            self.objectId = objectId
            self.uniqueKey = uniqueKey
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaUrlString = mediaUrlString
            self.latitude = latitude
            self.longitude = longitude
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        } else {
            return nil
        }
    }
}
