//
//  ParseClient.swift
//  On The Map
//
//  Created by Tobias Helmrich on 24.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class ParseClient {
    
    // MARK: - Properties
    
    let session = URLSession.shared
    
    // sharedInstance singleton
    static let sharedInstance = ParseClient()
    
    fileprivate init() {}
    
    
    // MARK: - Functions
    
    func getStudentLocation(withUniqueKey uniqueKey: String, completionHandlerForStudentLocation: @escaping (_ result: StudentLocation?, _ objectId: String?, _ error: Error?) -> Void) {
        
        // Set the parameter(s)
        let parameters = [
            ParameterKey.whereKey.rawValue: substitute(placeholder: ParameterPlaceholder.uniqueKey.rawValue, inValue: ParameterValue.uniqueKey.rawValue, withValue: uniqueKey)!
        ]
        
        // Create mutable request and set its properties
        let request = NSMutableURLRequest(url: getParseUrl(withParameters: parameters, andPathExtension: nil))
        request.addValue(HTTPHeaderFieldValue.applicationId.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.applicationId.rawValue)
        request.addValue(HTTPHeaderFieldValue.restApiKey.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.restApiKey.rawValue)
        
        print(request.url!)
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check if there was an error
            guard error == nil else {
                completionHandlerForStudentLocation(nil, nil, error!)
                return
            }
            
            // Check if the status code indicates that the response was successful
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForStudentLocation(nil, nil, ClientError.unsuccessfulStatusCode("Received unsuccessful status code."))
                    return
            }
            
            // Check if there is data
            guard let data = data else {
                completionHandlerForStudentLocation(nil, nil, ClientError.noDataReturned("No data was returned."))
                return
            }
            
            // Convert the raw data into a usable object
            Client.convertDataWithCompletionHandler(data: data) { (result, error) in
                
                // Check if there was an error
                guard error == nil else {
                    completionHandlerForStudentLocation(nil, nil, error!)
                    return
                }
                
                // Check if there is a result and cast it to a dictionary, then extract the actual results from the dictionary
                // by using the results key
                guard let result = result as? [String:Any],
                let results = result[JSONResponseKey.results.rawValue] as? [[String:Any]] else {
                    completionHandlerForStudentLocation(nil, nil, ClientError.noResultReceived("Didn't receive a result from data conversion."))
                    return
                }
                
                // Check if the results array has elements which means that there is at least one student location
                guard results.count > 0 else {
                    // if there is no element in the results array call the completion handler and pass it nil for every value
                    // which implies that there was no error but there is no location for the specified student
                    completionHandlerForStudentLocation(nil, nil, nil)
                    return
                }
                
                for result in results {
                    print("><><><><><><><><><><><><><><><><><><><><><><><><")
                    print(result)
                    print("><><><><><><><><><><><><><><><><><><><><><><><><")
                }
                
                print(results.count)
                
                // Create a student location from the last dictionary of the results array which holds all the locations for this student
                // (if the student has multiple locations which actually shouldn't be the case) as the last dictionary is the newest location
                guard let studentLocation = StudentLocation(fromDictionary: results[results.count - 1]),
                let objectId = results[results.count - 1][JSONResponseKey.objectId.rawValue] as? String else {
                    completionHandlerForStudentLocation(nil, nil, ClientError.parsingError("Couldn't create student location/object ID object from the provided dictionary: \(result)"))
                    return
                }
                
                // If the creation of the StudentLocation object succeeds pass it to the completion handler
                completionHandlerForStudentLocation(studentLocation, objectId, nil)
                
            }
            
        }
        
        task.resume()
        
    }
    
    func getStudentLocations(limit: Int?, skip: Int?, orderBy: String?, completionHandlerForStudentLocations: @escaping (_ studentLocations: [StudentLocation]?, _ error: Error?) -> Void) {
        
        // Create an empty [String:Any] dictionary
        var parameters = [String:Any]()
        
        // Check which parameters were passed in as arguments and add the passed ones to the parameters dictionary
        if let limit = limit {
            parameters[ParameterKey.limit.rawValue] = limit
        }
        
        if let skip = skip {
            parameters[ParameterKey.skip.rawValue] = skip
        }
        
        if let orderBy = orderBy {
            parameters[ParameterKey.order.rawValue] = orderBy
        }
        
        
        // Create the url depending on whether there are parameters or not
        let url: URL
        if parameters.count > 0 {
            url = getParseUrl(withParameters: parameters, andPathExtension: nil)
        } else {
            url = getParseUrl(withParameters: nil, andPathExtension: nil)
        }
        
        // Create and configure the request
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(HTTPHeaderFieldValue.applicationId.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.applicationId.rawValue)
        request.addValue(HTTPHeaderFieldValue.restApiKey.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.restApiKey.rawValue)
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check if there was an error
            guard error == nil else {
                completionHandlerForStudentLocations(nil, error!)
                return
            }
            
            // Check if the status code indicates a successful request
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForStudentLocations(nil, ClientError.unsuccessfulStatusCode("Received unsuccessful status code."))
                    return
            }
            
            // Check if there is data
            guard let data = data else {
                completionHandlerForStudentLocations(nil, ClientError.noDataReturned("No data was returned."))
                return
            }

            // Convert the data to a JSON object
            Client.convertDataWithCompletionHandler(data: data) { (result, error) in
                
                // Check if there was an error
                guard error == nil else {
                    completionHandlerForStudentLocations(nil, error!)
                    return
                }
                
                // Check if the result can be casted to a dictionary
                guard let result = result as? [String:Any] else {
                    completionHandlerForStudentLocations(nil, ClientError.noResultReceived("Didn't receive result."))
                    return
                }
                
                // Extract the results key that holds an array of dictionaries
                guard let studentResults = result[JSONResponseKey.results.rawValue] as? [[String:Any]] else {
                    completionHandlerForStudentLocations(nil, ClientError.keyNotFound("Couldn't find key \(JSONResponseKey.results.rawValue)"))
                    return
                }
                
                // Create an empty StudentLocations array
                var studentLocations = [StudentLocation]()
                for studentResult in studentResults {
                    // Fill the studentLocations array by creating StudentLocation objects from the dictionaries inside of studentResults
                    if let studentLocation = StudentLocation(fromDictionary: studentResult) {
                        print(studentLocation)
                        studentLocations.append(studentLocation)
                    }
                }
                
                completionHandlerForStudentLocations(studentLocations, nil)
                
            }
            
        }
        
        task.resume()
        
    }
    
    func post(studentLocation: StudentLocation, completionHandlerForPOST: @escaping (_ success: Bool) -> Void) {
        // Create and configure the request
        let request = NSMutableURLRequest(url: getParseUrl(withParameters: nil, andPathExtension: nil))
        request.httpMethod = "POST"
        request.addValue(HTTPHeaderFieldValue.applicationId.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.applicationId.rawValue)
        request.addValue(HTTPHeaderFieldValue.restApiKey.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.restApiKey.rawValue)
        request.addValue(HTTPHeaderFieldValue.contentType.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.contentType.rawValue)
        
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.uniqueKey)\", \"firstName\": \"\(studentLocation.firstName)\", \"lastName\": \"\(studentLocation.lastName)\",\"mapString\": \"\(studentLocation.mapString)\", \"mediaURL\": \"\(studentLocation.mediaUrlString)\",\"latitude\": \(studentLocation.latitude), \"longitude\": \(studentLocation.longitude)}".data(using: .utf8)
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                completionHandlerForPOST(false)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForPOST(false)
                    return
            }
            
            guard let data = data else {
                completionHandlerForPOST(false)
                return
            }
            
            Client.convertDataWithCompletionHandler(data: data) { (result, error) in
                guard error == nil else {
                    completionHandlerForPOST(false)
                    return
                }
                
                guard let result = result as? [String:Any] else {
                    completionHandlerForPOST(false)
                    return
                }
                
                // Check if there is an objectId key in the result dictionary which means that it's the wanted result
                guard let _ = result[JSONResponseKey.objectId.rawValue] as? String else {
                    completionHandlerForPOST(false)
                    return
                }
                
                completionHandlerForPOST(true)
                
            }
        
        }
        
        task.resume()
        
    }
    
    func updateStudentLocation(withStudentLocation studentLocation: StudentLocation, forObjectId objectId: String, completionHandlerForUpdate: @escaping (_ success: Bool) -> Void) {
        // Create and configure the request
        let request = NSMutableURLRequest(url: getParseUrl(withParameters: nil, andPathExtension: "/\(objectId)"))
        request.httpMethod = "PUT"
        request.addValue(HTTPHeaderFieldValue.applicationId.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.applicationId.rawValue)
        request.addValue(HTTPHeaderFieldValue.restApiKey.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.restApiKey.rawValue)
        request.addValue(HTTPHeaderFieldValue.contentType.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.contentType.rawValue)
        
        // Pass the new studentLocation's values to the http body
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.uniqueKey)\", \"firstName\": \"\(studentLocation.firstName)\", \"lastName\": \"\(studentLocation.lastName)\",\"mapString\": \"\(studentLocation.mapString)\", \"mediaURL\": \"\(studentLocation.mediaUrlString)\",\"latitude\": \(studentLocation.latitude), \"longitude\": \(studentLocation.longitude)}".data(using: .utf8)
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                completionHandlerForUpdate(false)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForUpdate(false)
                return
            }
            
            guard let data = data else {
                completionHandlerForUpdate(false)
                return
            }
            
            Client.convertDataWithCompletionHandler(data: data) { (result, error) in
                guard error == nil else {
                    completionHandlerForUpdate(false)
                    return
                }
                
                guard let result = result as? [String:Any] else {
                    completionHandlerForUpdate(false)
                    return
                }
                
                guard let _ = result[JSONResponseKey.updatedAt.rawValue] else {
                    completionHandlerForUpdate(false)
                    return
                }
                
                completionHandlerForUpdate(true)
                
            }
            
        }
        
        task.resume()
        
    }
    
    
    // MARK: - Helper functions
    
    func getParseUrl(withParameters parameters: [String:Any]?, andPathExtension pathExtension: String?) -> URL {
        // Create a URLComponents object and set its properties
        var urlComponents = URLComponents()
        urlComponents.scheme = Constant.scheme.rawValue
        urlComponents.host = Constant.host.rawValue
        if let pathExtension = pathExtension {
            urlComponents.path = "\(Constant.studentLocationApiPath.rawValue)\(pathExtension)"
        } else {
            urlComponents.path = Constant.studentLocationApiPath.rawValue
        }
        
        
        // Check if parameters were passed to the function
        if let parameters = parameters {
            // Create an empty array of URLQueryItem objects and assign it to the queryItems property of the urlComponents object
            urlComponents.queryItems = [URLQueryItem]()
            
            // Turn all the passed in parameters into query items and append them to the urlComponents object's queryItems array
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems!.append(queryItem)
            }
        }
        
        
        // Return the resulting URL by accessing the URLComponents object's url property
        return urlComponents.url!
    }
    
    // This method takes a placeholder (e.g. uniqueKey) and checks if the placeholder exists in the given value
    // (where it has to be written inside of curly braces). If it does it replaces the placeholder and the curly braces
    // with the passed value and returns the original string with the placeholder replaced, if not it returns nil
    func substitute(placeholder: String, inValue value: String, withValue replaceValue: String) -> String? {
        if value.range(of: "{\(placeholder)}") != nil {
            return value.replacingOccurrences(of: "{\(placeholder)}", with: replaceValue)
        } else {
            return nil
        }
    }
    
}
