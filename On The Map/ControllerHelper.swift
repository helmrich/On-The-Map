//
//  ControllerHelper.swift
//  On The Map
//
//  Created by Tobias Helmrich on 09.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

class ControllerHelper {
    
    func presentAlertController(withMessage message: String, onViewController presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            presentingViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    // This function takes a string (which should be a string that represents a URL) as a parameter and then returns
    // an optional URL. The purpose of this function is to provide some tolerance on how the URL is entered as some
    // students may type in an URL like "www.google.com" which basically is a correct URL but can't be used to open a
    // URL in the browser via UIApplication's open function.
    static func createUrl(fromUrlString urlString: String) -> URL? {
        // Make all letters of the URL string lowercased
        var urlString = urlString.lowercased()
        
        // Replace all occurrences of "http://", "https://" or "www." in the URL string
        urlString = urlString.replacingOccurrences(of: "https://", with: "")
        urlString = urlString.replacingOccurrences(of: "http://", with: "")
        urlString = urlString.replacingOccurrences(of: "www.", with: "")
        
        // Separate the URL into components which are divided by "/"
        let urlStringComponents = urlString.components(separatedBy: "/")
        
        // Create a URLComponents object
        var urlComponents = URLComponents()
        
        // Set the scheme to http (if the website has https as a protocol it will be set to https automatically)
        urlComponents.scheme = "http"
        
        // Set the first element of the urlStringComponents array as the host
        urlComponents.host = urlStringComponents[0]
        
        // Iterate over all the URL string components except the first one (because that's the host) and add them
        // to the path string. When done, set the path to the path string's value
        var pathString = ""
        for component in urlStringComponents.dropFirst() {
            pathString = "\(pathString)/\(component)"
        }
        urlComponents.path = pathString
        
        
        // Return the resulting URL component's URL
        return urlComponents.url
        
    }
}
