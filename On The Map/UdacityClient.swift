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
    let sharedClient = Client.sharedInstance
    
    // sharedInstance singleton
    static let sharedInstance = UdacityClient()
    
    var sessionId: String? = nil
    var accountKey: String? = nil
    
    // The init is overridden as fileprivate so that no other files can create an instance of UdacityClient,
    // thus the only instance can be the sharedInstance singleton
    fileprivate init() {}
    
    
    // MARK: - Functions
    
    func getPublicUserData(method: String, completionHandlerForPublicUserData: @escaping (_ userData: [String:Any]?, _ error: String?) -> Void) {
        
        // Check if there is an account key
        guard let accountKey = accountKey else {
            completionHandlerForPublicUserData(nil, "No account key was provided.")
            return
        }
        
        // Add the account key to the URL
        let methodWithAccountKey = "\(method)/\(accountKey)"
        let url = udacityUrl(withMethod: methodWithAccountKey)
        
        sharedClient.taskForGET(withUrl: url, headerFields: nil) { (data, errorMessage) in
            
            // Check if there was an error
            guard errorMessage == nil else {
                completionHandlerForPublicUserData(nil, errorMessage!)
                return
            }
            
            // Check if data was received
            guard let data = data else {
                completionHandlerForPublicUserData(nil, ClientError.noDataReceived.rawValue)
                return
            }
            
            // Skip the first 5 characters of the response as theses characters are used for security purposes in the Udacity API
            let newData = data.subdata(in: 5..<data.count)
            
            Client.convertDataWithCompletionHandler(data: newData) { result, errorMessage in
                
                // Check if there was an error
                guard errorMessage == nil else {
                    completionHandlerForPublicUserData(nil, errorMessage!)
                    return
                }
                
                // Check if the result can be turned into a usable object
                guard let result = result as? [String:Any] else {
                    completionHandlerForPublicUserData(nil, ClientError.deserializationError.rawValue)
                    return
                }
                
                // Extract the neccessary informations from the result dictionary (first name, last name)
                guard let user = result[JSONResponseKey.user.rawValue] as? [String:Any],
                    let firstName = user[JSONResponseKey.firstName.rawValue] as? String,
                    let lastName = user[JSONResponseKey.lastName.rawValue] as? String else {
                        completionHandlerForPublicUserData(nil, ClientError.keyNotFound.rawValue)
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
    }
    
    
    func postSession(method: String, userName: String, userPassword: String, facebookAccessToken: String? = nil, completionHandlerForSessionId: @escaping (_ sessionId: String?, _ errorMessage: String?) -> Void) {
        
        // Create mutable request and set HTTP method
        let request = NSMutableURLRequest(url: udacityUrl(withMethod: method))
        request.httpMethod = "POST"
        
        // HTTP Header fields
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // HTTP body
        let jsonBody: String
        if let facebookAccessToken = facebookAccessToken {
            // If there is a facebook access token send it with the JSON body,
            jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(facebookAccessToken)\"}}"
        } else {
            // if not, use the provided Udacity credentials
            jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(userPassword)\"}}"
        }
        request.httpBody = jsonBody.data(using: .utf8)
        
        // Make the request and cast the NSMutableURLRequest as a URL request when passing it to the data task
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check if there was an error
            guard error == nil else {
                completionHandlerForSessionId(nil, error!.localizedDescription)
                return
            }
            
            // Check if there is a status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandlerForSessionId(nil, "Couldn't get status code")
                return
            }
            
            // Check if the status code is 403 (forbidden) which means that the provided password and/or email is wrong
            guard statusCode != 403 else {
                completionHandlerForSessionId(nil, UdacityClientError.wrongCredentials.rawValue)
                return
            }
            
            // Check if the status code was successful
            guard statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForSessionId(nil, ClientError.unsuccessfulStatusCode.rawValue)
                    return
            }
            
            // Check if data was retrieved
            guard let data = data else {
                completionHandlerForSessionId(nil, ClientError.noDataReceived.rawValue)
                return
            }
            
            // Skip the first 5 characters of the response as theses characters are used for security purposes in the Udacity API
            let newData = data.subdata(in: 5..<data.count)
            
            Client.convertDataWithCompletionHandler(data: newData) { result, errorMessage in
                
                // Check if there was an error
                guard errorMessage == nil else {
                    completionHandlerForSessionId(nil, errorMessage!)
                    return
                }
                
                // Check if the result can be turned into a usable object
                guard let result = result as? [String:Any] else {
                    completionHandlerForSessionId(nil, ClientError.deserializationError.rawValue)
                    return
                }
                
                // Extract the needed value from the parsed data (session ID)
                guard let session = result[JSONResponseKey.session.rawValue] as? [String:Any],
                    let sessionId = session[JSONResponseKey.id.rawValue] as? String else {
                        completionHandlerForSessionId(nil, ClientError.keyNotFound.rawValue)
                        return
                }
                
                // Extract the needed value from the parsed data (account key)
                guard let account = result[JSONResponseKey.account.rawValue] as? [String:Any],
                    let accountKey = account[JSONResponseKey.key.rawValue] as? String else {
                        completionHandlerForSessionId(nil, ClientError.keyNotFound.rawValue)
                        return
                }
                
                // Call the completion handler and pass it the session ID ...
                completionHandlerForSessionId(sessionId, nil)
                // and set the UdacityClient's sessionId and accountKey properties
                self.sessionId = sessionId
                self.accountKey = accountKey
            }
            
        }
        
        task.resume()
        
    }
    
    func logout(completionHandlerForLogout: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {

        // Log out from Facebook
        // MARK: - Uncomment for Facebook login
//        FBSDKLoginManager().logOut()
        
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
            // Check if there was an error
            guard error == nil else {
                completionHandlerForLogout(false, error!.localizedDescription)
                return
            }
            
            // Check if the status code was successful
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForLogout(false, ClientError.unsuccessfulStatusCode.rawValue)
                    return
            }
            
            // Check if data was retrieved
            guard let data = data else {
                completionHandlerForLogout(false, ClientError.noDataReceived.rawValue)
                return
            }
            
            // Skip first 5 characters of the response
            let newData = data.subdata(in: Range(5...data.count))
            
            Client.convertDataWithCompletionHandler(data: newData) { result, errorMessage in
                
                // Check if there was an error
                guard error == nil else {
                    completionHandlerForLogout(false, errorMessage)
                    return
                }
                
                // Check if the result can be turned into a usable object
                guard let result = result as? [String:Any] else {
                    completionHandlerForLogout(false, ClientError.noResultReceived.rawValue)
                    return
                }
                
                // Check if the session key can be found in the result
                // which verifies that the wanted object was returned
                guard let _ = result[JSONResponseKey.session.rawValue] else {
                    completionHandlerForLogout(false, ClientError.keyNotFound.rawValue)
                    return
                }
                
                // Reset the session ID and call the completion handler
                self.sessionId = nil
                completionHandlerForLogout(true, nil)
                
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
