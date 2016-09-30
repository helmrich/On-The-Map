//
//  UdacitySignUpViewController.swift
//  On The Map
//
//  Created by Tobias Helmrich on 29.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class UdacitySignUpViewController: UIViewController {

    // MARK: - Properties
    
    var signUpPageUrl: URL? = nil
    
    
    // MARK: - Outlets and Actions

    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let signUpPageUrl = URL(string: UdacityClient.Constant.signUpPageUrlString.rawValue) {
            let signUpPageRequest = URLRequest(url: signUpPageUrl)
            webView.loadRequest(signUpPageRequest)
        }
        
    }
    
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}
