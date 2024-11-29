//
//  LoginData.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation

struct LoginData: Codable {
    let udacity: UserData
}

struct UserData: Codable {
    let username: String
    let password: String
}
