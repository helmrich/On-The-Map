//
//  Client.swift
//  On The Map
//
//  Created by Tobias Helmrich on 25.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class Client {
    
    // MARK: - Properties
    
    let session = URLSession.shared
    
    // sharedInstance singleton
    static let sharedInstance = Client()
    
    fileprivate init() {}
    
    
    // MARK: - Functions
    
    func taskForGET(withUrl url: URL, headerFields: [String:String]?, completionHandlerForGET: @escaping (_ data: Data?, _ errorMessage: String?) -> Void) {
        // Create a mutable request and set its properties
        let request = NSMutableURLRequest(url: url)
        if let headerFields = headerFields {
            for (headerFieldName, headerFieldValue) in headerFields {
                request.addValue(headerFieldValue, forHTTPHeaderField: headerFieldName)
            }
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Check if there was an error
            guard error == nil else {
                completionHandlerForGET(nil, error!.localizedDescription)
                return
            }
            
            // Check if the status code indicates that the response was successful
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForGET(nil, "Unsuccessful response. Status code: \((response as? HTTPURLResponse)?.statusCode)")
                    return
            }
            
            guard let data = data else {
                completionHandlerForGET(nil, "Didn't receive data.")
                return
            }
            
            completionHandlerForGET(data, nil)
            
        }
        
        task.resume()
        
    }
    
    static func convertDataWithCompletionHandler(data: Data, completionHandler: (_ result: Any?, _ errorMessage: String?) -> Void) {
        
        var result: Any
        do {
            result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandler(nil, "Couldn't deserialize data into a usable object.")
            return
        }
        
        completionHandler(result, nil)
        
    }
}
