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
    
    
    // MARK: - Outlets and Actions
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    // Change the appearance of the buttons when they're tapped
    @IBAction func loginButtonTouchedDown(_ sender: AnyObject) {
        loginButton.backgroundColor = UIColor.darkenColor(originalRed: 1, originalGreen: 1, originalBlue: 1, by: 0.015)
    }
    
    @IBAction func loginButtonTouchedUp(_ sender: AnyObject) {
        loginButton.backgroundColor = UIColor.white
    }
    
    @IBAction func loginButtonTouchedUpOutside(_ sender: AnyObject) {
        loginButton.backgroundColor = UIColor.white
    }
    
    @IBAction func facebookLoginButtonTouchedDown(_ sender: AnyObject) {
        facebookLoginButton.backgroundColor = UIColor.darkenColor(originalRed: 59 / 255, originalGreen: 89 / 255, originalBlue: 152 / 255, by: 0.015)
    }
    
    @IBAction func facebookLoginButtonTouchedUp(_ sender: AnyObject) {
        facebookLoginButton.backgroundColor = UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1)
    }
    
    @IBAction func facebookLoginButtonTouchedUpOutside(_ sender: AnyObject) {
        facebookLoginButton.backgroundColor = UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
