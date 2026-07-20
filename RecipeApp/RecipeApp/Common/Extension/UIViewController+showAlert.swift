//
//  UIViewController+showAlert.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import UIKit

extension UIViewController {
     func showAlert(with error: NetworkError) {
        let alert = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert
        )
        let closeAction = UIAlertAction(title: "Close", style: .cancel)
        alert.addAction(closeAction)
        present(alert, animated: true)
    }
}
