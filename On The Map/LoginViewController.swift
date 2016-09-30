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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var udacityLogoImageView: UIImageView!
    
    @IBAction func loginButtonTouchedDown(_ sender: AnyObject) {
        loginButton.backgroundColor = UIColor.darkenColor(originalRed: 1, originalGreen: 1, originalBlue: 1, by: 0.05)
    }
    
    @IBAction func loginButtonTouchedUp(_ sender: AnyObject) {
        loginButton.backgroundColor = UIColor.white
        errorLabel.isHidden = true
        // Check if a username and password were provided ...
        if let username = emailTextField.text,
            let password = passwordTextField.text {
            if username.characters.count > 0 && password.characters.count > 0 {
                // if so, try to log in with the provided values
                login(username: username, password: password)
            } else {
                // if not, display an error
                showError(message: "Please provide a username and password.")
            }
        }
    }
    
    @IBAction func loginButtonTouchedUpOutside(_ sender: AnyObject) {
        loginButton.backgroundColor = UIColor.white
    }
    
    @IBAction func facebookLoginButtonTouchedDown(_ sender: AnyObject) {
        facebookLoginButton.backgroundColor = UIColor.darkenColor(originalRed: 59 / 255, originalGreen: 89 / 255, originalBlue: 152 / 255, by: 0.05)
    }
    
    @IBAction func facebookLoginButtonTouchedUp(_ sender: AnyObject) {
        facebookLoginButton.backgroundColor = UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1)
    }
    
    @IBAction func facebookLoginButtonTouchedUpOutside(_ sender: AnyObject) {
        facebookLoginButton.backgroundColor = UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1)
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the text field's delegates to be the LoginViewController
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Set corner radius for buttons and text fields
        loginButton.layer.cornerRadius = 4
        facebookLoginButton.layer.cornerRadius = 4
        emailTextField.layer.cornerRadius = 2
        passwordTextField.layer.cornerRadius = 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the observers for keyboard notifications
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil, using: keyboardWillShow)
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil, using: keyboardWillHide)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the observers for keyboard notifications
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Functions for notifications
    
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
    
    
    // MARK: - Functions
    
    func login(username: String, password: String) {
        UdacityClient.sharedInstance.postSession(method: UdacityClient.Method.session.rawValue, userName: username, userPassword: password) { (success, sessionId, error) in
            guard error == nil else {
                self.showError(message: "Received an error when trying to log in. Try again.")
                return
            }
            
            guard success else {
                self.showError(message: "Unsuccessful response.")
                return
            }
            
            guard let _ = sessionId else {
                self.showError(message: "Couldn't get session ID.")
                return
            }
            
            
            // Login successful -> Instantiate the tab bar controller from storyboard and present it
            DispatchQueue.main.async {
                let studentLocationTabBarController = self.storyboard!.instantiateViewController(withIdentifier: "studentLocationTabBarController")
                self.present(studentLocationTabBarController, animated: true, completion: nil)
            }
            
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
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








