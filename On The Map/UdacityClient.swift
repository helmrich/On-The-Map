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
    
    // sharedInstance singleton
    static let sharedInstance = UdacityClient()
    
    var sessionId: String? = nil
    var accountKey: String? = nil
    
    // The init is overridden as fileprivate so that no other files can create an instance of UdacityClient,
    // thus the only instance can be the sharedInstance singleton
    fileprivate init() {}
    
    
    // MARK: - Functions
    
    func getPublicUserData(method: String, completionHandlerForPublicUserData: @escaping (_ userData: [String:Any]?, _ error: Error?) -> Void) {
        
        // Check if there is an account key
        guard let accountKey = accountKey else {
            completionHandlerForPublicUserData(nil, ClientError.missingAccountKey("No account key was provided."))
            return
        }
        
        // Add the account key to the URL
        let methodWithAccountKey = "\(method)/\(accountKey)"
        
        // Create the request
        let request = URLRequest(url: udacityUrl(withMethod: methodWithAccountKey))
        
        // Make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            // Check if there was an error
            guard error == nil else {
                completionHandlerForPublicUserData(nil, ClientError.parsingError(error!.localizedDescription))
                return
            }
            
            // Check if the status code was successful
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForPublicUserData(nil, ClientError.unsuccessfulStatusCode("Didn't receive successful status code."))
                    return
            }
            
            // Check if data was retrieved
            guard let data = data else {
                completionHandlerForPublicUserData(nil, ClientError.noDataReturned("No data was returned!"))
                return
            }
            
            // Skip the first 5 characters of the response as theses characters are used for security purposes in the Udacity API
            let newData = data.subdata(in: 5..<data.count)
            
            Client.convertDataWithCompletionHandler(data: newData) { result, error in
                
                // Check if there was an error
                guard error == nil else {
                    completionHandlerForPublicUserData(nil, error)
                    return
                }
                
                // Check if the result can be turned into a usable object
                guard let result = result as? [String:Any] else {
                    completionHandlerForPublicUserData(nil, ClientError.parsingError("Couldn't turn deserialized JSON into a usable object!"))
                    return
                }
                
                // Extract the neccessary informations from the result dictionary (first name, last name)
                guard let user = result[JSONResponseKey.user.rawValue] as? [String:Any],
                let firstName = user[JSONResponseKey.firstName.rawValue] as? String,
                let lastName = user[JSONResponseKey.lastName.rawValue] as? String else {
                    completionHandlerForPublicUserData(nil, ClientError.keyNotFound("Key \(JSONResponseKey.user.rawValue), \(JSONResponseKey.firstName.rawValue) and/or \(JSONResponseKey.lastName.rawValue) not found."))
                    return
                }
                
                // Save the extracted values and the unique (account) key in a dictionary and pass it to the completion handler
                let userData = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "uniqueKey": accountKey
                ]
                
                completionHandlerForPublicUserData(userData, nil)
                
            }
        }
        
        task.resume()
        
    }
    
    func postSession(method: String, userName: String, userPassword: String, completionHandlerForSessionId: @escaping (_ success: Bool, _ sessionId: String?, _ error: Error?) -> Void) {
        
        // Create mutable request and set HTTP method
        let request = NSMutableURLRequest(url: udacityUrl(withMethod: method))
        request.httpMethod = "POST"
        
        // HTTP Header fields
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // HTTP body
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(userPassword)\"}}"
        request.httpBody = jsonBody.data(using: .utf8)
        
        // Make the request and cast the NSMutableURLRequest as a URL request when passing it to the data task
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check if there was an error
            guard error == nil else {
                completionHandlerForSessionId(false, nil, ClientError.parsingError(error!.localizedDescription))
                return
            }
            
            // Check if the status code was successful
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForSessionId(false, nil, ClientError.unsuccessfulStatusCode("Didn't receive successful status code."))
                    return
            }
            
            // Check if data was retrieved
            guard let data = data else {
                completionHandlerForSessionId(false, nil, ClientError.noDataReturned("No data was returned!"))
                return
            }
            
            // Skip the first 5 characters of the response as theses characters are used for security purposes in the Udacity API
            let newData = data.subdata(in: 5..<data.count)
            
            Client.convertDataWithCompletionHandler(data: newData) { result, error in
                
                // Check if there was an error
                guard error == nil else {
                    completionHandlerForSessionId(false, nil, error)
                    return
                }
                
                // Check if the result can be turned into a usable object
                guard let result = result as? [String:Any] else {
                    completionHandlerForSessionId(false, nil, ClientError.parsingError("Couldn't turn deserialized JSON into a usable object!"))
                    return
                }
                
                // Extract the needed value from the parsed data (session ID)
                guard let session = result[JSONResponseKey.session.rawValue] as? [String:Any],
                    let sessionId = session[JSONResponseKey.id.rawValue] as? String else {
                        completionHandlerForSessionId(false, nil, ClientError.keyNotFound("Couldn't find key [\(JSONResponseKey.session.rawValue)][\(JSONResponseKey.id.rawValue)]"))
                        return
                }
                
                // Extract the needed value from the parsed data (account key)
                guard let account = result[JSONResponseKey.account.rawValue] as? [String:Any],
                    let accountKey = account[JSONResponseKey.key.rawValue] as? String else {
                        completionHandlerForSessionId(false, nil, ClientError.keyNotFound("Couldn't find key [\(JSONResponseKey.account.rawValue)][\(JSONResponseKey.key.rawValue)]"))
                        return
                }
                
                // Call the completion handler and pass it the session ID ...
                completionHandlerForSessionId(true, sessionId, nil)
                // and set the UdacityClient's sessionId and accountKey properties
                self.sessionId = sessionId
                self.accountKey = accountKey
            }
            
        }
        
        task.resume()
        
    }
    
    func deleteSession(completionHandlerForDelete: @escaping (_ success: Bool) -> Void) {
        // Create mutable request and set its HTTP method
        let request = NSMutableURLRequest(url: udacityUrl(withMethod: Method.session.rawValue))
        request.httpMethod = "DELETE"
        
        // If there is already an existing XSRF-TOKEN cookie in the shared cookie storage assign it to the xsrfCookie
        // variable and set the X-XSRF-TOKEN HTTP header field to this cookie's value
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        if let cookies = sharedCookieStorage.cookies {
            for cookie in cookies {
                if cookie.name  == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                completionHandlerForDelete(false)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForDelete(false)
                    return
            }
            
            guard let data = data else {
                completionHandlerForDelete(false)
                return
            }
            
            // Skip first 5 characters of the response
            let newData = data.subdata(in: Range(5...data.count))
            
            Client.convertDataWithCompletionHandler(data: newData) { result, error in
                
                // Check if there was an error
                guard error == nil else {
                    completionHandlerForDelete(false)
                    return
                }
                
                // Check if the result can be turned into a usable object
                guard let result = result as? [String:Any] else {
                    completionHandlerForDelete(false)
                    return
                }
                
                // Check if the session key can be found in the result
                // which verifies that the wanted object was returned
                guard let _ = result[JSONResponseKey.session.rawValue] else {
                    completionHandlerForDelete(false)
                    return
                }
                
                self.sessionId = nil
                completionHandlerForDelete(true)
                
            }
            
        }
        
        task.resume()
        
    }
    
    
    // MARK: - Helper functions
    
    func udacityUrl(withMethod method: String) -> URL {
        // Create a URLComponents object and set its properties
        var urlComponents = URLComponents()
        urlComponents.scheme = Constant.scheme.rawValue
        urlComponents.host = Constant.host.rawValue
        urlComponents.path = "\(Constant.apiPath.rawValue)/\(method)"
        
        // Return the resulting URL by accessing the URLComponents object's url property
        return urlComponents.url!
    }
    
}








