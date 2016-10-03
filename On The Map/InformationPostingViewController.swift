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
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.5) {
            self.questionTextStackView.alpha = 0
            self.linkTextView.alpha = 1
            self.locationTextContainerView.alpha = 0
            self.findButtonContainerView.alpha = 0
//            self.findButton.titleLabel?.text = "Submit"
            self.submitButton.alpha = 1
            self.cancelButton.tintColor = UIColor.white
            self.view.backgroundColor = UIColor(red: 81 / 255, green: 137 / 255, blue: 180 / 255, alpha: 1)
        }
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Functions
    

}

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
