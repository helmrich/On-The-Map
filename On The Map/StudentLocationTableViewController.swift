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
    
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var studentLocationTableView: UITableView!
    
    
    // MARK: - Lifecycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - Functions
    
    func setStudentLocationTableView(withStudentLocations studentLocations: [StudentLocation]) {
        DispatchQueue.main.async {
            self.studentLocationTableView.reloadData()
        }
    }
}


// MARK: - Table View Data Source

extension StudentLocationTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let studentLocations = StudentLocationDataSource.sharedInstance.studentLocations {
            return studentLocations.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell by using an identifier and cast it to be of StudentLocationTableViewCell type
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationCell", for: indexPath) as! StudentLocationTableViewCell
        
        // If the data source's studentLocations property that contains all the student locations is not nil...
        if let studentLocations = StudentLocationDataSource.sharedInstance.studentLocations {
            // set the current student by using the current indexPath's row property as an index for the studentLocations array...
            let currentStudent = studentLocations[indexPath.row]
            // and Set the cell's labels to the appropriate values
            cell.studentNameLabel.text = "\(currentStudent.firstName) \(currentStudent.lastName)"
            cell.linkLabel.text = currentStudent.mediaUrlString
        } else {
            // If the studentLocations array is nil, set the cell's labels to empty strings
            cell.studentNameLabel.text = ""
            cell.linkLabel.text = ""
        }
        return cell
    }
}


// MARK: - Table View Delegate

extension StudentLocationTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Check if there are student locations
        guard let studentLocations = StudentLocationDataSource.sharedInstance.studentLocations else {
            return
        }
        
        // Check if a URL can be created from the given URL string
        guard let url = ControllerHelper.createUrl(fromUrlString: studentLocations[indexPath.row].mediaUrlString) else {
            presentAlertController(withMessage: "Couldn't create URL")
            return
        }
        
        // Open the URL in the browser
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
}
