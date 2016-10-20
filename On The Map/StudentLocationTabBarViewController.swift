//
//  StudentLocationTabBarViewController.swift
//  On The Map
//
//  Created by Tobias Helmrich on 07.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class StudentLocationTabBarViewController: UITabBarController {

    // MARK: - Properties
    var postSuccessful = false
    

    // MARK: - Outlets and Actions
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBAction func logout() {
        // Delete the session
        UdacityClient.sharedInstance.logout { (success, errorMessage) in
            
            // Check if there was an error
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: errorMessage!)
                return
            }
            
            // Check if the logout was successful
            if success {
                // If the deletion was successful dismiss the tab bar controller (with its view controllers),
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                // if not, present an alert controller with an appropriate message
                self.presentAlertController(withMessage: "Logout failed")
            }
        }
    }
    
    @IBAction func reload() {
        setupViewControllers()
    }
    
    @IBAction func goToInformationPosting() {
        
        // Instantiate the information posting view controller from storyboard
        let informationPostingViewController = storyboard?.instantiateViewController(withIdentifier: "informationPostingVC") as! InformationPostingViewController
        
        // Check if there is an account/unique key
        guard let uniqueKey = UdacityClient.sharedInstance.accountKey else {
            presentAlertController(withMessage: "Couldn't get unique account key")
            return
        }
        
        ParseClient.sharedInstance.getStudentLocation(withUniqueKey: uniqueKey) { (studentLocation, _, errorMessage) in
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: errorMessage!)
                return
            }
            
            // Check if the searched student location is NOT empty...
            guard studentLocation != nil else {
                // if it is empty, present the information posting view controller
                DispatchQueue.main.async {
                    self.present(informationPostingViewController, animated: true, completion: nil)
                }
                return
            }
            
            // if not, show an alert view that informs the user that there already is an existing student location with this account
            // and ask whether the existing student location should be overwritten or the creation of a new location should be cancelled
            
            // Create the alert controller
            let alertController = UIAlertController(title: nil, message: "You have already posted a Student Location. Would you like to overwrite your current Location?", preferredStyle: .alert)
            
            // Create and add the two actions to the alert controller (overwrite and cancel)
            // When "Overwrite" is tapped the information posting view controller should be presented
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: { (alertAction) in
                informationPostingViewController.shouldUpdateStudentLocation = true
                self.present(informationPostingViewController, animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(overwriteAction)
            alertController.addAction(cancelAction)
            
            // Present the alert controller on the main thread
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the navigation bar's title and logout button's font to Open Sans with a font size of 17
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!
        ]
        
        logoutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViewControllers()
        
    }
    
    
    // MARK: - Functions
    func setupViewControllers() {
        StudentLocationDataSource.sharedInstance.getStudentLocationsForDataSource(limit: 100, skip: 0, orderBy: "-\(ParseClient.ParameterValue.updatedAt.rawValue)") { (success, errorMessage) in
            
            // Check if there was an error
            guard errorMessage == nil else {
                self.presentAlertController(withMessage: "\(errorMessage!) Try to refresh.")
                return
            }
            
            // Check if the request was successful
            guard success else {
                self.presentAlertController(withMessage: DataSourceError.studentLocationsRequestFailed.rawValue)
                return
            }
            
            // Check if there are student locations in the data source
            guard let studentLocations = StudentLocationDataSource.sharedInstance.studentLocations else {
                self.presentAlertController(withMessage: DataSourceError.noStudentLocations.rawValue)
                return
            }
            
            // Check which view controller is selected in the tab bar, then cast the view controller to the
            // appropriate class and call the method that is used to setup the view with student locations
            if let mapViewController = self.selectedViewController as? StudentLocationMapViewController {
                mapViewController.placeAnnotations(forStudentLocations: studentLocations)
            }
            
            if let tableViewController = self.selectedViewController as? StudentLocationTableViewController {
                tableViewController.setStudentLocationTableView(withStudentLocations: studentLocations)
            }
            
        }
    }

}
