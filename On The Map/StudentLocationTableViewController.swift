//
//  StudentLocationTableViewController.swift
//  On The Map
//
//  Created by Tobias Helmrich on 30.09.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UIViewController {

    // MARK: - Properties
    var studentLocations: [StudentLocation]? = nil
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var studentLocationTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBAction func reloadTableView() {
        setStudentLocationTableView()
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation bar's title and the logoutButton UIBarButtonItem's font to Open Sans
        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!
        ]
        
        logoutButton.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!
            ], for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setStudentLocationTableView()
    }
    
    
    // MARK: - Functions
    
    func setStudentLocationTableView() {
        // Get the last 100 students that posted their location
        ParseClient.sharedInstance.getStudentLocations(limit: 100, skip: nil, orderBy: nil) { (studentLocations, error) in
            guard error == nil else {
                return
            }
            
            guard studentLocations != nil else {
                return
            }
            
            self.studentLocations = studentLocations
            DispatchQueue.main.async {
                self.studentLocationTableView.reloadData()
            }
        }
    }

}


// MARK: - Table View Data Source

extension StudentLocationTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let studentLocations = studentLocations {
            return studentLocations.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationCell", for: indexPath) as! StudentLocationTableViewCell
        if let studentLocations = studentLocations {
            let currentStudent = studentLocations[indexPath.row]
            cell.studentNameLabel.text = "\(currentStudent.firstName) \(currentStudent.lastName)"
        } else {
            cell.studentNameLabel.text = ""
        }
        return cell
    }
}


// MARK: - Table View Delegate

extension StudentLocationTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Check if there are student locations
        guard let studentLocations = studentLocations else {
            return
        }
        
        // Get the provided URL's string from the selected student
        let providedUrlString = studentLocations[indexPath.row].mediaUrlString
        
        // Check if the string can be turned into a URL
        guard let url = URL(string: providedUrlString) else {
            return
        }
        
        // Open the URL in the browser
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
}
