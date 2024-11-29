//
//  StudentLocation.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation

struct StudentLocation: Codable {
    let uniqueKey: String       
    let firstName: String
    let lastName:  String
    var mapString: String
    var mediaURL:  String
    var latitude:  Double
    var longitude: Double
}
