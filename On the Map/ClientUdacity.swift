//
//  ClientUdacity.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation
import CoreLocation

class ClientUdacity {
    
    enum CustomError: Error {
        case decodingError
        case encodingError
        case loginError
        case networkError
        case userdataError
    }
    
    struct Profile {
        static var accountKey = ""          // from createSessionResponse, for getUserData, for addLocation
        static var sessionId = ""           // from createSessionResponse
        static var firstName = ""           // from getUser
        static var lastName = ""            // from getUser
        static var objectId = ""            // from addLocation
    }
    
    enum Endpoint {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case createSession
        case deleteSession
        case addLocation
        case getUserData
        case getLocationList
        case signupUdacity
        
        private var stringValue: String {
            switch self {
            case .createSession: return Endpoint.base + "/session"
            case .deleteSession: return Endpoint.base + "/session"
            case .getUserData: return Endpoint.base + "/users/" + Profile.accountKey
            case .addLocation: return Endpoint.base + "/StudentLocation"
            case .getLocationList: return Endpoint.base + "/StudentLocation?order=-updatedAt"
            case .signupUdacity: return "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated"
            }
        }
        
        var url: URL { return URL(string: stringValue)! }
    }
    
    // Get list of all students with locations
    class func getLocationList(completion: @escaping (Result<[StudentInformation], CustomError>) -> Void) {
        let request = URLRequest(url: Endpoint.getLocationList.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion (.failure(.networkError))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AllStudents.self, from: data)
                    completion(.success(response.results))
                    
                } catch {
                    
                    completion (.failure(.decodingError))
                }
            }
        }
        task.resume()
    }
    
    // Get public user data
    class func getUserData (completion: @escaping (Result<UserDataResponse, CustomError>) -> Void) {
        
        let request = URLRequest(url: Endpoint.getUserData.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                guard let data = data?.subdata(in: 5..<data!.count), error == nil else {
                    completion (.failure(.userdataError))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(UserDataResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion (.failure(.userdataError))
                }
            }
        }
        task.resume()
    }
    
    // Post a new location
    class func addLocation(studentLocation: StudentLocation, completion: @escaping (Result<AddLocationResponse, CustomError>) -> Void) {
        //var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        var request = URLRequest(url: Endpoint.addLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(studentLocation)
        }    catch  {
            completion (.failure(.encodingError))
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion (.failure(.networkError))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AddLocationResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    
                    completion (.failure(.decodingError))
                }
            }
        }
        task.resume()
    }
    
    // Log in
    class func createSession(userData: UserData, completion: @escaping (Result<CreateSessionResponse, CustomError>) -> Void) {
        var request = URLRequest(url: Endpoint.createSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(LoginData(udacity: userData))
        }    catch  {
            completion (.failure(.encodingError))
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data?.subdata(in: 5..<data!.count), error == nil else {
                    completion (.failure(.networkError))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(CreateSessionResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion (.failure(.loginError))
                }
                // {"status":403,"error":"Account not found or invalid credentials."}
            }
        }
        task.resume()
    }
    
    // Log out
    class func deleteSession(completion: @escaping (Result<String, CustomError>) -> Void) {
        var request = URLRequest(url: Endpoint.deleteSession.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let _ = data?.subdata(in: 5..<data!.count), error == nil else {
                    completion (.failure(.networkError))
                    return
                }
                completion (.success("Logged out"))
                Profile.accountKey = ""
                Profile.sessionId = ""
                Profile.firstName = ""
                Profile.lastName = ""
                Profile.objectId = ""
            }
        }
        task.resume()
    }
}







