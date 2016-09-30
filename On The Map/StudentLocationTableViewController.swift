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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}


// MARK: - Table View Data Source

extension StudentLocationTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Implement
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Implement
        return UITableViewCell()
    }
}


// MARK: - Table View Delegate

extension StudentLocationTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Implement
    }
}
