//
//  AlertManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import UIKit

class AlertManager {
    static func showAlert(on viewController: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        
        viewController.present(alert, animated: true)
    }
    
    static func showErrorAlert(on viewController: UIViewController, error: Error) {
        showAlert(on: viewController, title: "Error", message: error.localizedDescription)
    }
    
    static func showPermissionAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        viewController.present(alert, animated: true)
    }
}
