//
//  UserDataResponseswift.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation

struct UserDataResponse: Codable {
    let lastName: String
    let firstName: String
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
        case key
    }
}
