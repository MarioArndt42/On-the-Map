//
//  CrateSessionResponse.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation

struct CreateSessionResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String    
}

struct Session: Codable {
    let id: String
    let expiration: String
}

