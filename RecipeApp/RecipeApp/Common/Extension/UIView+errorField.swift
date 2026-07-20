//
//  UIView+errorField.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import UIKit

extension UIView {
    // Give UIView Container error effect
    func setFieldError() {
        layer.borderColor = UIColor.systemRed.cgColor
        layer.borderWidth = 1.5
    }
    // Remove error effect from UIView Container
    func clearFieldError(defaultColor: UIColor = UIColor.systemGray5) {
        layer.borderColor = defaultColor.cgColor
        layer.borderWidth = 1
    }
}
