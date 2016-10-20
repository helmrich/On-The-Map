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

    // MARK: - Outlets and Actions
    @IBOutlet weak var studentLocationsMapView: MKMapView!
    
    
    // MARK: - Lifecycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the region of the map that should be displayed in the beginning to the whole world
        studentLocationsMapView.region = MKCoordinateRegionForMapRect(MKMapRectWorld)
        
    }
    
    
    // MARK: - Functions
    
    func placeAnnotations(forStudentLocations studentLocations: [StudentLocation]) {
        
        // Instantiate an array of MKPointAnnotation objects and iterate over the array of student locations that
        // was passed in as a parameter. Then create a point annotation for all the student locations and set the
        // neccessary properties (coordinate, title = name, subtitle = URL) and append it to the created array
        var studentPointAnnotations = [MKPointAnnotation]()
        for studentLocation in studentLocations {
            let studentPointAnnotation = MKPointAnnotation()
            studentPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
            studentPointAnnotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            studentPointAnnotation.subtitle = studentLocation.mediaUrlString
            studentPointAnnotations.append(studentPointAnnotation)
        }
        
        DispatchQueue.main.async {
            // Remove all "old" student locations from the map view
            self.studentLocationsMapView.removeAnnotations(self.studentLocationsMapView.annotations)
            
            // Add the current student locations to the map view
            self.studentLocationsMapView.addAnnotations(studentPointAnnotations)
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
        // Unwrap the tapped annotation view's annotation and its subtitle which contains the URL string,
        // then create a usable URL and open it in the default browser
        if let annotation = view.annotation,
        let subtitle = annotation.subtitle,
        let urlString = subtitle,
        let url = ControllerHelper.createUrl(fromUrlString: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
