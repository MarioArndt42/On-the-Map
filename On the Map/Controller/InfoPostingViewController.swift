//
//  InfoPostingViewController.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import UIKit
import MapKit

class InfoPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    // InfoPostingViewController closed -> reload map or table
    var isDismissedTableView: (() -> Void)?
    var isDismissedMapView: (() -> Void)?
    
    var studentLocation: StudentLocation!
    
    @IBOutlet weak var postingMap: MKMapView!
    
    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var urlText: UITextField!
    
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationText.becomeFirstResponder()
        locationText.delegate = self
        urlText.delegate = self
        postingMap.delegate = self
        setMapModus(false)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        setMapModus(false)
        postingMap.removeAnnotations(self.postingMap.annotations)
        locationText.becomeFirstResponder()
    }
    
    @IBAction func findPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.activityIndicator.startAnimating()
        self.findPosition(address: locationText.text!)
    }
    
    @IBAction func cancelPosting(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    // Submit new location
    @IBAction func submitPressed(_ sender: Any) {
        setMapModus(false)
        ClientUdacity.addLocation(studentLocation: studentLocation, completion: { result in
            switch result {
            case .success(let response):
                ClientUdacity.Profile.objectId = response.objectId
                self.dismiss(animated: true) {
                    // InfoPostingView closed -> Reload data
                    self.isDismissedMapView?()
                    self.isDismissedTableView?()
                }
            case .failure(let error):
                self.backPressed(self)
                self.showAlert(message: error.localizedDescription, title: "Error Add Location")
            }
        })
    }
    
    
    
    // Geocode find position
    private func findPosition(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { [self] (placemarks, error) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                backPressed(self)
                showAlert(message: error!.localizedDescription, title: "Location Not Found")
                return
            }
            
            guard let placemarks = placemarks,
                  let placemark = placemarks.first else {
                return
            }
            
            self.postingMap.isHidden = false
            self.submitButton.isHidden = false
            self.addPlacemarkToMap(placemark :placemark)
        }
    }
    
    // Add annotation to map
    private func addPlacemarkToMap(placemark :CLPlacemark) {
        let coordinate = placemark.location!.coordinate
        
        studentLocation = StudentLocation(
            uniqueKey: ClientUdacity.Profile.accountKey,
            firstName: ClientUdacity.Profile.firstName,
            lastName: ClientUdacity.Profile.lastName,
            mapString: locationText.text ?? "",
            mediaURL: urlText.text ?? "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
        annotation.subtitle = studentLocation.mediaURL
        postingMap.addAnnotation(annotation)
        focusMap(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    // focus map on new location
    func focusMap(latitude: Double, longitude: Double) {
        let focusLocation = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        let region = MKCoordinateRegion(center: focusLocation, span: span)
        postingMap.setRegion(region, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationText {
            urlText.becomeFirstResponder()
        } else {
            findPressed(self)
        }
        return true
    }
    
    // First enter new location, ater pressing FIND show map
    func setMapModus(_ mapModus: Bool) {
        locationText.isEnabled = !mapModus
        urlText.isEnabled = !mapModus
        findButton.isEnabled = !mapModus
        postingMap.isHidden = !mapModus
        submitButton.isEnabled = !mapModus
        submitButton.isHidden = !mapModus
        backButton.isEnabled = mapModus
    }
    
}
