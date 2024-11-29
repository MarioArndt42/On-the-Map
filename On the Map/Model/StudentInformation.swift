//
//  StudentInfo.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation

struct StudentInformation: Codable {
    let objectId: String
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let updatedAt: String?
    
}


