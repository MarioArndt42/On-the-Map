//
//  ViewController.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//


import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func buttonPosting(_ sender: Any) {
        showInfoPostingView(self)
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        reloadData()
    }
    
    @IBAction func buttonLogout(_ sender: Any) {
        
        ClientUdacity.deleteSession(completion: { result in
            switch result {
            case .success(_):
                self.dismiss(animated: true)
            case .failure(let error):
                self.showAlert(message: error.localizedDescription, title: "Logout Error")
            }
        })
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        mapView.delegate = self
        self.reloadData()
    }
    
    // Get list of all students with locations
    func reloadData() {
        ClientUdacity.getLocationList(completion: { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let students):
                self.createAnnotations(locations: students)
            case .failure(let error):
                self.showAlert(message: error.localizedDescription, title: "Error loading locations")
            }
        })
    }
    
    // Create an MKPointAnnotation for each student location
    func createAnnotations(locations: [StudentInformation]) {
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            let lat = CLLocationDegrees(location.latitude  ?? 0)
            let long = CLLocationDegrees(location.longitude  ?? 0)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = location.firstName ?? " "
            let last = location.lastName ?? " "
            let mediaURL = location.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        // Add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let urlString = view.annotation?.subtitle ?? ""
            guard let url = URL(string: urlString!), UIApplication.shared.canOpenURL(url)
            else {
                self.showAlert(message: "Can't open link", title: "Invalid link")
                return
            }
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    // Call InfoPostingView to enter location
    func showInfoPostingView(_ sender: Any) {
        
        let postingController = self.storyboard!.instantiateViewController(withIdentifier: "InfoPostingViewController") as! InfoPostingViewController
        self.present(postingController, animated: true, completion: nil)
        
        // InfoPostingView closed -> Reload map
        postingController.isDismissedMapView = { [weak self] in
            self?.reloadData()
        }
    }
    
}

/*
 // MARK: - Sample Data
 
 // Some sample data. This is a dictionary that is more or less similar to the
 // JSON data that you will download from Parse.
 
 func hardCodedLocationData() -> [[String : Any]] {
 return  [
 [
 "createdAt" : "2015-02-24T22:27:14.456Z",
 "firstName" : "Jessica",
 "lastName" : "Uelmen",
 "latitude" : 28.1461248,
 "longitude" : -82.75676799999999,
 "mapString" : "Tarpon Springs, FL",
 "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
 "objectId" : "kj18GEaWD8",
 "uniqueKey" : 872458750,
 "updatedAt" : "2015-03-09T22:07:09.593Z"
 ], [
 "createdAt" : "2015-02-24T22:35:30.639Z",
 "firstName" : "Gabrielle",
 "lastName" : "Miller-Messner",
 "latitude" : 35.1740471,
 "longitude" : -79.3922539,
 "mapString" : "Southern Pines, NC",
 "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
 "objectId" : "8ZEuHF5uX8",
 "uniqueKey" : 2256298598,
 "updatedAt" : "2015-03-11T03:23:49.582Z"
 ], [
 "createdAt" : "2015-02-24T22:30:54.442Z",
 "firstName" : "Jason",
 "lastName" : "Schatz",
 "latitude" : 37.7617,
 "longitude" : -122.4216,
 "mapString" : "18th and Valencia, San Francisco, CA",
 "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
 "objectId" : "hiz0vOTmrL",
 "uniqueKey" : 2362758535,
 "updatedAt" : "2015-03-10T17:20:31.828Z"
 ], [
 "createdAt" : "2015-03-11T02:48:18.321Z",
 "firstName" : "Jarrod",
 "lastName" : "Parkes",
 "latitude" : 34.73037,
 "longitude" : -86.58611000000001,
 "mapString" : "Huntsville, Alabama",
 "mediaURL" : "https://linkedin.com/in/jarrodparkes",
 "objectId" : "CDHfAy8sdp",
 "uniqueKey" : 996618664,
 "updatedAt" : "2015-03-13T03:37:58.389Z"
 ]
 ]
 }
 */



