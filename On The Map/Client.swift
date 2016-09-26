//
//  Client.swift
//  On The Map
//
//  Created by Tobias Helmrich on 25.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class Client {
    
    static func convertDataWithCompletionHandler(data: Data, completionHandler: (_ result: Any?, _ error: Error?) -> Void) {
        
        var result: Any
        do {
            result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandler(nil, ClientError.serializationError("Couldn't deserialize data into a usable object."))
            return
        }
        
        completionHandler(result, nil)
        
    }
}
