//
//  OnTheMapButton.swift
//  On The Map
//
//  Created by Tobias Helmrich on 03.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class OnTheMapButton: UIButton {
    
    // MARK: - Properties
    
    var activityIndicatorView: UIActivityIndicatorView? = nil
    

    // MARK: - Overridden methods
    
    override func awakeFromNib() {
        layer.cornerRadius = 4
    }
    
    
    // MARK: - Additional methods
    
    // This method toggles the loading status of a button that has an activity indicator attached
    // to it by setting all the neccessary properties to achieve an appropriate look for the button
    // depending on whether it's waiting for something to happen or not
    func toggleLoadingStatus() {
        
        // Check if an activity indicator view was added to the button
        guard let activityIndicatorView = activityIndicatorView else {
            print("This button doesn't have an activity indicator view.")
            return
        }
        
        // Check if the button is enabled,
        if isEnabled {
            // if the button is enabled...
            
            // show the activity indicator view and let it start the animation
            activityIndicatorView.startAnimating()
            activityIndicatorView.isHidden = false
            
            // set the button's background and title colors to the current button
            // background color with a lower alpha value for transparency
            // to achieve a "disabled look" and disable the button
            set(backgroundColorAlphaValue: 0.7, titleColorAlphaValue: 0)
            isEnabled = false
        } else {
            // if the button is disabled...
            
            // stop the activity indicator view's animation and hide it
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
            
            // set the button's background and title colors to 1 so they're fully visible again
            // and enable the button
            set(backgroundColorAlphaValue: 1, titleColorAlphaValue: 1)
            isEnabled = true
        }
    }
    
    // This method adds an activity indicator view to the center of the button
    func addCenteredActivityIndicator(activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()) {
        
        // Add the activity indicator view to the button as a subview
        addSubview(activityIndicatorView)
        
        // Set the neccessary constraints
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        
        // Assign the activity indicator view to the button's activityIndicatorView property
        self.activityIndicatorView = activityIndicatorView
    }
    
    // This method sets the alpha values for both the background and
    // title color (for the normal state) of the button
    func set(backgroundColorAlphaValue: CGFloat, titleColorAlphaValue: CGFloat) {
        backgroundColor = backgroundColor?.withAlphaComponent(backgroundColorAlphaValue)
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(titleColorAlphaValue), for: .normal)
    }

}
