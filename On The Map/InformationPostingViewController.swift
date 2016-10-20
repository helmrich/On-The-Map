//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Tobias Helmrich on 02.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    // MARK: - Properties
    var isKeyboardActive = false
    var coordinate: CLLocationCoordinate2D? = nil
    
    // This variable checks if the student location should be updated (which means that it already exists),
    // if its value is false it should post a new student location
    var shouldUpdateStudentLocation: Bool = false
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findButton: OnTheMapButton!
    @IBOutlet weak var submitButton: OnTheMapButton!
    @IBOutlet weak var locationTextContainerView: UIView!
    @IBOutlet weak var findButtonContainerView: UIView!
    @IBOutlet weak var questionTextStackView: UIStackView!
    @IBOutlet weak var geocodingActivityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func buttonTouchDown(_ sender: OnTheMapButton) {
        sender.set(backgroundColorAlphaValue: 0.7, titleColorAlphaValue: 1)
    }
    
    @IBAction func buttonTouchUp(_ sender: OnTheMapButton) {
        sender.set(backgroundColorAlphaValue: 1, titleColorAlphaValue: 1)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: AnyObject) {
        
        setSubmitView(toShow: true)
        findButton.toggleLoadingStatus()
        
        
        self.getLocation(fromString: self.locationTextView.text) { (coordinate, region, errorMessage) in
            
            DispatchQueue.main.async {
                self.findButton.toggleLoadingStatus()
                self.geocodingActivityIndicatorView.stopAnimating()
                self.geocodingActivityIndicatorView.alpha = 0
            }
            
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: errorMessage!)
                self.setSubmitView(toShow: false)
                return
            }
            
            guard let coordinate = coordinate else {
                self.presentAlertController(withMessage: "Couldn't get coordinate.")
                self.setSubmitView(toShow: false)
                return
            }
            
            // If there is a coordinate, assign it to the view controller's coordinate property
            self.coordinate = coordinate
            
            guard let region = region else {
                self.presentAlertController(withMessage: "Couldn't get region.")
                self.setSubmitView(toShow: false)
                return
            }
            
            // Set the coordinate region with the region's center as the center coordinate and the region's radius as
            // the latitudinal and longitudinal meters
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, region.radius, region.radius)
            
            // Create an annotation and set its coordinate to the location's coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Add the annotation to the map view and set the region with an animation
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(coordinateRegion, animated: true)
            
        }
    }
    
    @IBAction func submitEntry() {
        
        // When the submit button is pressed the linkTextView should resign its
        // first responder status
        linkTextView.resignFirstResponder()
        
        // Check if the link text's value is the default value or if there is no text and display an alert if either one is true
        guard linkTextView.text != "Enter a Link to Share Here" && linkTextView.text.characters.count > 0 else {
            presentAlertController(withMessage: "Please provide a link.")
            return
        }
        
        // Unwrap the locationTextView and linkTextView's texts
        guard let locationText = locationTextView.text,
        let linkText = linkTextView.text else {
            presentAlertController(withMessage: "No location and/or link provided")
            return
        }
        
        self.submitButton.toggleLoadingStatus()
        
        // Get the public user data
        UdacityClient.sharedInstance.getPublicUserData(method: UdacityClient.Method.users.rawValue) { (userData, errorMessage) in
            
            DispatchQueue.main.async {
                self.submitButton.toggleLoadingStatus()
            }
            
            // Check if there was an error
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: "\(errorMessage!) Try again.")
                return
            }
            
            // Check if user data was received
            guard let userData = userData else {
                self.presentAlertController(withMessage: "Couldn't get user data.")
                return
            }
            
            // Check if the needed values from the userData dictionary (first name, last name, unique key) can be extracted
            guard let firstName = userData["firstName"] as? String,
                let lastName = userData["lastName"] as? String,
                let uniqueKey = userData["uniqueKey"] as? String else {
                    self.presentAlertController(withMessage: "Couldn't find keys in the userData dictionary.")
                    return
            }
            
            // Check if the view controller's coordinate property is not nil
            guard let coordinate = self.coordinate else {
                self.presentAlertController(withMessage: "Couldn't get coordinate")
                return
            }
            
            // Create a student location with the received values
            let studentLocation = StudentLocation(firstName: firstName, lastName: lastName, mapString: locationText, mediaUrlString: linkText, latitude: coordinate.latitude, longitude: coordinate.longitude, uniqueKey: uniqueKey)
            
            if self.shouldUpdateStudentLocation {
                // If the student location should be updated:
                // Get the student location that should be updated
                ParseClient.sharedInstance.getStudentLocation(withUniqueKey: uniqueKey) { (_, objectId, error) in
                    
                    // Check if there was an error
                    guard error == nil else {
                        self.presentAlertController(withMessage: "Couldn't update location. Try again.")
                        return
                    }
                    
                    // Check if there is an object ID
                    guard let objectId = objectId else {
                        self.presentAlertController(withMessage: "Couldn't find student location for the specified student.")
                        return
                    }
                    
                    // Update the student location with the given object ID and check whether the updating was successful or not
                    ParseClient.sharedInstance.updateStudentLocation(withStudentLocation: studentLocation, forObjectId: objectId) { (success, errorMessage) in
                        
                        guard errorMessage == nil else {
                            self.presentAlertController(withMessage: errorMessage!)
                            return
                        }
                        
                        if success {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            self.presentAlertController(withMessage: "Couldn't update location. Try again.")
                        }
                    }
                }
            } else {
                // If the student location shouldn't be updated:
                // Post the student location
                ParseClient.sharedInstance.post(studentLocation: studentLocation) { (success, errorMessage) in
                    
                    guard errorMessage == nil else {
                        self.presentAlertController(withMessage: errorMessage!)
                        return
                    }
                    
                    if success {
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    self.presentAlertController(withMessage: "Couldn't post location. Try again.")

                }
            }
        }
        
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a gesture recognizer for taps and add it to the view controller's main view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        submitButton.addCenteredActivityIndicator()
        findButton.addCenteredActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add observers for keyboard notifications
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil, using: keyboardWillShow)
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil, using: keyboardWillHide)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observers for keyboard notifications
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Functions
    
    // This function takes an address string and forward geocodes the string to a coordinate. Besides the coordinate and a possible error
    // message the completion handler has a region parameter which can be used to set the visible region
    func getLocation(fromString string: String, completionHandlerForLocation: @escaping (_ coordinate: CLLocationCoordinate2D?, _ region: CLCircularRegion?, _ errorMessage: String?) -> Void) {
        
        // Create an instance of CLGeocoder
        let geocoder = CLGeocoder()
        
        // Forward geocode the address string with the appropriate geocoder's method
        geocoder.geocodeAddressString(string) { (placemark, error) in
            
            // Check if there was an error
            guard error == nil else {
                completionHandlerForLocation(nil, nil, error!.localizedDescription)
                return
            }
            
            // Check if a placemark could be created
            guard let placemark = placemark else {
                completionHandlerForLocation(nil, nil, "Couldn't get placemark.")
                return
            }
            
            // Check if there is a region value and if it can be casted as a CLCircularRegion object
            // Note: If there are multiple placemarks the first result of the returned placemarks will be used in this case
            // as it's the most common placemark. If it's not the placemark the user was looking for there is still the possibility
            // to input a more precise description of the location's name
            guard let region = placemark[0].region as? CLCircularRegion else {
                completionHandlerForLocation(nil, nil, "Couldn't get region.")
                return
            }
            
            // Check if there is a value for the location
            guard let location = placemark[0].location else {
                completionHandlerForLocation(nil, nil, "Couldn't get location.")
                return
            }

            // Get the coordinate and pass it and the region to the completion handler
            let coordinate = location.coordinate
            completionHandlerForLocation(coordinate, region, nil)
            
        }
        
    }
    
    // This function will be called when there is a tap gesture on the InformationPostingViewController's main view
    func hideKeyboard() {
        // It then checks if a text view is the first responder and if it is...
        if locationTextView.isFirstResponder {
            // It checks if the text view is empty
            if locationTextView.text == "" {
                // and sets it back to the default value if that's the case
                locationTextView.text = "Enter Your Location Here"
            }
            // and it resigns its first responder status
            locationTextView.resignFirstResponder()
        }
        
        if linkTextView.isFirstResponder {
            if linkTextView.text == "" {
                linkTextView.text = "Enter a Link to Share Here"
            }
            linkTextView.resignFirstResponder()
        }
    }
    
    // This function toggles the interface between the UI for finding a location and the UI for submitting the location with a link
    // by setting the views' properties accordingly
    func setSubmitView(toShow shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.5) {
                self.questionTextStackView.alpha = 0
                self.linkTextView.alpha = 1
                self.locationTextContainerView.alpha = 0
                self.findButtonContainerView.alpha = 0
                self.submitButton.alpha = 1
                self.cancelButton.tintColor = UIColor.white
                self.geocodingActivityIndicatorView.alpha = 1
                self.view.backgroundColor = UIColor(red: 81 / 255, green: 137 / 255, blue: 180 / 255, alpha: 1)
            }
            
            geocodingActivityIndicatorView.startAnimating()
            
        } else {
            UIView.animate(withDuration: 0.5) {
                self.questionTextStackView.alpha = 1
                self.linkTextView.alpha = 0
                self.locationTextContainerView.alpha = 1
                self.findButtonContainerView.alpha = 1
                self.submitButton.alpha = 0
                self.cancelButton.tintColor = UIColor(red: 81 / 255, green: 137 / 255, blue: 180 / 255, alpha: 1)
                self.geocodingActivityIndicatorView.alpha = 0
                self.view.backgroundColor = UIColor.white
            }
            
            geocodingActivityIndicatorView.stopAnimating()
            
        }
    }

}


// MARK: - Text View delegate

extension InformationPostingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // If a text view's text is the default value the text view should become
        // empty so the user can input the link
        if (textView.tag == 2 && textView.text == "Enter a Link to Share Here") || (textView.tag == 1 && textView.text == "Enter Your Location Here") {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // When text in the text view is changed check if it has a
        // value of "\n" that is a line break which means
        // that the user tapped return
        if text == "\n" {
            // if it is, the text view should resign as a first responder
            // and return false so there is no line break in the
            // input text
            textView.resignFirstResponder()
            return false
        }
        
        return true
        
    }
}

extension InformationPostingViewController {
    func keyboardWillShow(notification: Notification) {
        print(submitButton.frame.origin)
        // Check if the keyboard is currently displayed or not, if not the view should be moved
        // up and the isKeyboardActive variable should be set to true, if it's already displayed
        // nothing should happen as the view was already moved up before
        if !isKeyboardActive {
            // Get the userInfo dictionary that gets sent with the notification and get the key which contains the keyboard's height
            if let userInfo = notification.userInfo,
                let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                submitButton.frame.origin.y -= keyboardFrameEnd.cgRectValue.height
            }
            isKeyboardActive = true
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        // The view frame's origin y value can simply be set to 0 as it's the bottom of the screen
        if let userInfo = notification.userInfo,
            let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            submitButton.frame.origin.y += keyboardFrameEnd.cgRectValue.height
        }
        // When the keyboard will hide the isKeyboardActive variable should be reset to false
        isKeyboardActive = false
    }
}
