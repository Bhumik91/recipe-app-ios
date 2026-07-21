//
//  UIViewController+createLoadingIndicator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 22/07/26.
//
import UIKit

extension UIViewController {
    func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .label

        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return indicator
    }
}
