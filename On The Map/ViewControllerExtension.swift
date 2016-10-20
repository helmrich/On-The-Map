//
//  ViewControllerExtension.swift
//  On The Map
//
//  Created by Tobias Helmrich on 10.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlertController(withMessage message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func addTapGestureRecognizerForHidingKeyboard() {
        // Add a gesture recognizer for taps and add it to the view controller's main view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        // Resign the view (or any of its text field/text view's) first responder status so that the keyboard will hide
        view.endEditing(true)
    }
    
}
