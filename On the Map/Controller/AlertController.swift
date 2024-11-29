//
//  AlertController.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import UIKit

extension UIViewController {
    
    func showAlert(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
