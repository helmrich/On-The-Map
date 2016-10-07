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
    let uniqueKey: String
    var objectId: String?
    
    init(firstName: String, lastName: String, mapString: String, mediaUrlString: String, latitude: Double, longitude: Double, uniqueKey: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaUrlString = mediaUrlString
        self.latitude = latitude
        self.longitude = longitude
        self.uniqueKey = uniqueKey
    }
    
    init?(fromDictionary dictionary: [String:Any]) {
        if let firstName = dictionary[ParseClient.JSONResponseKey.firstName.rawValue] as? String,
        let lastName = dictionary[ParseClient.JSONResponseKey.lastName.rawValue] as? String,
        let latitude = dictionary[ParseClient.JSONResponseKey.latitude.rawValue] as? Double,
        let longitude = dictionary[ParseClient.JSONResponseKey.longitude.rawValue] as? Double,
        let mapString = dictionary[ParseClient.JSONResponseKey.mapString.rawValue] as? String,
        let mediaUrlString = dictionary[ParseClient.JSONResponseKey.mediaURL.rawValue] as? String,
        let uniqueKey = dictionary[ParseClient.JSONResponseKey.uniqueKey.rawValue] as? String {
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaUrlString = mediaUrlString
            self.latitude = latitude
            self.longitude = longitude
            self.uniqueKey = uniqueKey
        } else {
            return nil
        }
    }
}
