//
//  StudentLocationDataSource.swift
//  On The Map
//
//  Created by Tobias Helmrich on 09.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class StudentLocationDataSource {
    
    // MARK: - Properties
    var studentLocations: [StudentLocation]?
    
    // sharedInstance singleton
    static let sharedInstance = StudentLocationDataSource()
    
    fileprivate init() {}

    
    // MARK: - Functions
    
    func getStudentLocationsForDataSource(limit: Int?, skip: Int?, orderBy: String?, completionHandlerForStudentLocations: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        ParseClient.sharedInstance.getStudentLocations(limit: limit, skip: skip, orderBy: orderBy) { (studentLocations, errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForStudentLocations(false, errorMessage!)
                return
            }
            
            guard let studentLocations = studentLocations else {
                completionHandlerForStudentLocations(false, "No student locations found.")
                return
            }
            
            self.studentLocations = studentLocations
            completionHandlerForStudentLocations(true, nil)
            
        }
    }
}
