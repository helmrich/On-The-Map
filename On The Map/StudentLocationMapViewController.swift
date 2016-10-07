//
//  StudentLocationMapViewController.swift
//  On The Map
//
//  Created by Tobias Helmrich on 02.10.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationMapViewController: UIViewController {

    // MARK: - Properties
    var studentLocations: [StudentLocation]? = nil
    var studentPointAnnotations = [MKPointAnnotation]()
    
    
    // MARK: - Outlets and Actions
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var studentLocationsMapView: MKMapView!
    
    @IBAction func reloadMapView() {
        placeAnnotations()
    }
    
    @IBAction func goToInformationPosting() {
        
        let informationPostingViewController = storyboard?.instantiateViewController(withIdentifier: "informationPostingVC") as! InformationPostingViewController
        
        guard let uniqueKey = UdacityClient.sharedInstance.accountKey else {
            print("No unique key provided.")
            return
        }
        
        print(uniqueKey)
        
        ParseClient.sharedInstance.getStudentLocation(withUniqueKey: uniqueKey) { (studentLocation, _, error) in
            guard error == nil else {
                print(error!.localizedDescription)
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
        
        // Set the region of the map that should be displayed in the beginning to the whole world
        studentLocationsMapView.region = MKCoordinateRegionForMapRect(MKMapRectWorld)
        placeAnnotations()
    }
    
    // MARK: - Functions
    
    func placeAnnotations() {
        ParseClient.sharedInstance.getStudentLocations(limit: 100, skip: 0, orderBy: nil) { (studentLocations, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            guard let studentLocations = studentLocations else {
                print("Couldn't get student locations.")
                return
            }
            
            self.studentLocations = studentLocations
            
            for studentLocation in studentLocations {
                let studentPointAnnotation = MKPointAnnotation()
                studentPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
                studentPointAnnotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                studentPointAnnotation.subtitle = studentLocation.mediaUrlString
                self.studentPointAnnotations.append(studentPointAnnotation)
            }
            
            DispatchQueue.main.async {
                self.studentLocationsMapView.addAnnotations(self.studentPointAnnotations)
            }
            
        }
    }

}


// MARK: - Map View delegate

extension StudentLocationMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Cast the annotation to the MKPointAnnotation type
        let annotation = annotation as! MKPointAnnotation
        
        // Create an annotation view as a mutable variable as it will be set depending on if an annotation view can be dequeued
        // or not later
        var annotationView: MKAnnotationView
        
        // Check if an annotation view with the specified identifier ("pin") can be dequeued
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            // If so, set the dequeued annotation view's annotation property to the current annotation
            dequeuedAnnotationView.annotation = annotation
            annotationView = dequeuedAnnotationView
        } else {
            // If not, create a MKPinAnnotationView with the current annotation as a parameter and set the reuse identifier
            // to "pin". Also enable the ability to show a callout and set the right callout accessory view to a button
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation,
        let subtitle = annotation.subtitle,
        let urlString = subtitle,
        let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}














