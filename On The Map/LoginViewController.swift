//
//  LoginViewController.swift
//  On The Map
//
//  Created by Tobias Helmrich on 27.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Properties
    var isKeyboardActive = false
    
    
    // MARK: - Outlets and Actions
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginButton: OnTheMapButton!
    @IBOutlet weak var facebookButton: OnTheMapButton!
    @IBOutlet weak var udacityLogoImageView: UIImageView!
    
    @IBAction func buttonTouchDown(_ sender: OnTheMapButton) {
        sender.set(backgroundColorAlphaValue: 0.7, titleColorAlphaValue: 1)
    }
    
    @IBAction func buttonTouchUp(_ sender: OnTheMapButton) {
        sender.set(backgroundColorAlphaValue: 1, titleColorAlphaValue: 1)
    }
    
    @IBAction func loginButtonTouchUp(_ sender: AnyObject) {
        // Check if a username and password were provided ...
        if let username = emailTextField.text,
            let password = passwordTextField.text {
            if username.characters.count > 0 && password.characters.count > 0 {
                // if so, try to log in with the provided values
                login(username: username, password: password)
                loginButton.toggleLoadingStatus()
            } else {
                // if not, display an error
                presentAlertController(withMessage: "No username and/or password provided")
            }
        }
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the text field's delegates to be the LoginViewController
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add the facebook login button, make the LoginViewController its delegate and set its constraints
        let facebookLoginButton = FBSDKLoginButton()
        facebookLoginButton.delegate = self
        view.addSubview(facebookLoginButton)
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: facebookLoginButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: facebookLoginButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: facebookLoginButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        
        loginButton.addCenteredActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Make the password text field empty so that the password isn't filled out
        // after logging out
        passwordTextField.text = ""
        
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
    
    func login(username: String, password: String) {
        UdacityClient.sharedInstance.postSession(method: UdacityClient.Method.session.rawValue, userName: username, userPassword: password) { (sessionId, errorMessage) in
            
            DispatchQueue.main.async {
                self.loginButton.toggleLoadingStatus()
            }
            
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: errorMessage!)
                return
            }
            
            guard let _ = sessionId else {
                self.presentAlertController(withMessage: "Couldn't get session ID")
                return
            }
            
            
            // Login successful -> Instantiate the tab bar controller from storyboard and present it
            DispatchQueue.main.async {
                let studentLocationTabBarController = self.storyboard!.instantiateViewController(withIdentifier: "studentLocationNavigationController")
                self.present(studentLocationTabBarController, animated: true, completion: nil)
            }
            
        }
    }
    
    // Set the status bar style to light content which makes the text white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }
    
}


// MARK: - Text Field delegate methods

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // When the return button is pressed on the keyboard the text field should resign its first responder status
        // which means that it will be deselected
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - Functions for notifications

extension LoginViewController {
    func keyboardWillShow(notification: Notification) {
        // Check if the keyboard is currently displayed or not, if not the view should be moved
        // up and the isKeyboardActive variable should be set to true, if it's already displayed
        // nothing should happen as the view was already moved up before
        if !isKeyboardActive {
            // Get the userInfo dictionary that gets sent with the notification and get the key which contains the keyboard's height
            if let userInfo = notification.userInfo,
                let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                // The view is moved up by half of the height of the keyboard because it's not neccessary to display
                // the facebook login button on the bottom when typing in the Udacity user information as the user obviously
                // wants to log in via Udacity
                view.frame.origin.y -= keyboardFrameEnd.cgRectValue.height / 2
            }
            // Make the udacity logo transparent
            udacityLogoImageView.alpha = 0.2
            isKeyboardActive = true
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        // The view frame's origin y value can simply be set to 0 as it's the bottom of the screen
        view.frame.origin.y = 0
        // Make the udacity logo intransparent
        udacityLogoImageView.alpha = 1
        // When the keyboard will hide the isKeyboardActive variable should be reset to false
        isKeyboardActive = false
    }
}


// MARK: - Facebook SDK login button delegate

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard error == nil else {
            presentAlertController(withMessage: error.localizedDescription)
            return
        }
        
        guard let result = result else {
            presentAlertController(withMessage: "Couldn't get result from facebook login.")
            return
        }
        
        guard result.token != nil else {
            presentAlertController(withMessage: "Facebook login failed. Try again.")
            return
        }
        
        let accessToken = result.token.tokenString
        
        UdacityClient.sharedInstance.postSession(method: UdacityClient.Method.session.rawValue, userName: "", userPassword: "", facebookAccessToken: accessToken) { (sessionId, errorMessage) in
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: errorMessage!)
                return
            }
            
            guard let _ = sessionId else {
                self.presentAlertController(withMessage: "Couldn't get session ID.")
                return
            }
            
            // Login successful -> Instantiate the tab bar controller from storyboard and present it
            DispatchQueue.main.async {
                let studentLocationTabBarController = self.storyboard!.instantiateViewController(withIdentifier: "studentLocationNavigationController")
                self.present(studentLocationTabBarController, animated: true, completion: nil)
            }
            
        }
        
    }
}
