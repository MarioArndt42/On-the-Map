//
//  LogInViewController.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import Foundation
import UIKit

class LogInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func signup(_ sender: Any) {
        UIApplication.shared.open(ClientUdacity.Endpoint.signupUdacity.url, options: [:], completionHandler: nil)
    }
    
    // Login Button pressed
    @IBAction func pressedLoginButton(_ sender: UIButton) {
        checkLogin()
    }
    
    func checkLogin() {
        if emailTextField.text == "" {
            self.showAlert(message: "Invalid email address, please enter a valid email address", title: "Error Email")
            emailTextField.becomeFirstResponder()
        }
        else    {
            if passwordTextField.text == "" {
                self.showAlert(message: "Invalid password, please enter a password", title: "Error Password")
                passwordTextField.becomeFirstResponder()
            }
            else {
                self.view.endEditing(true)
                setLoggingIn(true)
                let userData = UserData(username: emailTextField.text!, password: passwordTextField.text!)
                
                // Login Udacity server
                ClientUdacity.createSession(userData: userData, completion: completionLogin(result:))
            }
        }
    }
    
    // Completion handler for login and get user data from Udacity server
    func completionLogin(result: Result<CreateSessionResponse, ClientUdacity.CustomError> ) {
        
        switch result {
        case .success(let response):
            ClientUdacity.Profile.accountKey = response.account.key
            ClientUdacity.Profile.sessionId = response.session.id
            ClientUdacity.getUserData(completion: completionUserData(result:))
            
        case .failure(let error):
            switch error {
            case .loginError:
                loginFailure(message: error.localizedDescription, title: "Wrong email or password")
            case .networkError:
                loginFailure(message: error.localizedDescription, title: "Network error")
            default:
                loginFailure(message: error.localizedDescription, title: "Unknown error")
            }
        }
    }
    
    func completionUserData(result: Result<UserDataResponse, ClientUdacity.CustomError>) {
        switch result {
        case .success(let response):
            ClientUdacity.Profile.firstName = response.firstName
            ClientUdacity.Profile.lastName = response.lastName
            
            //Show map
            self.loginSuccess(self)
            
        case .failure(let error):
            loginFailure(message: error.localizedDescription, title: "No user data found")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            checkLogin()
        }
        return true
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signupButton.isEnabled = !loggingIn
    }
    
    func loginSuccess(_ sender: Any) {
        setLoggingIn(false)
        emailTextField.text = ""
        passwordTextField.text = ""
        let tabBarController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        self.present(tabBarController, animated: true, completion: nil)
    }
    
    func loginFailure(message: String, title: String) {
        self.showAlert(message: message, title: title)
        setLoggingIn(false)
        emailTextField.becomeFirstResponder()
    }
    
}














